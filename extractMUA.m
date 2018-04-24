function extractMUA(processedDataRootDir, dataDirRoot, sessionName, pl2FileName, spkcChannelInd)

%% get PL2 file metadata
tic;
pl2FilePath = sprintf('%s/%s/%s', dataDirRoot, sessionName, pl2FileName);
dataInfo = PL2GetFileIndex(pl2FilePath);
Fs = dataInfo.TimestampFrequency;

fprintf('----------------------------\n');
fprintf('Extracting MUA from file: %s\n', pl2FilePath);
fprintf('Session: %s\n', sessionName);
fprintf('Channel index: %d\n', spkcChannelInd);
fprintf('Output to directory: %s\n\n', processedDataRootDir);

%% index all the SPKC channels
doesSPKCChannelHaveData = false(numel(dataInfo.AnalogChannels), 1);
fprintf('SPKC channels with data: ');
for i = 1:numel(dataInfo.AnalogChannels)
    if dataInfo.AnalogChannels{i}.Enabled && strcmp(dataInfo.AnalogChannels{i}.SourceName, 'SPKC') && ...
            dataInfo.AnalogChannels{i}.NumValues > 0 && ...
            dataInfo.AnalogChannels{i}.Channel <= 125 % SKIP extra analog signal data (ch 126-128)
        adInfo = PL2AdTimeSpan(pl2FilePath, dataInfo.AnalogChannels{i}.Name, 0, 0.01);
        if any(adInfo.Values)
            fprintf('%d ', i);
            doesSPKCChannelHaveData(i) = true;
        end
    end
end
fprintf('\n');

spkcChannelsToRun = find(doesSPKCChannelHaveData);

%% set up thresholding parameters
% adaptive thresholding: window ~250 seconds, adjusted to make each window
% equally sized
blockStartTimes = PL2StartStopTs(pl2FilePath, 'start');
blockStopTimes = PL2StartStopTs(pl2FilePath, 'stop');
fileStartTime = blockStartTimes(1); % include non-recorded time
fileStopTime = blockStopTimes(end);
fileTotalTime = fileStopTime - fileStartTime;
assert(fileStartTime == 0); % if not true, then the indexing later is off

adaptiveThreshWindowLengthOrig = 250; % seconds
nAdaptiveThreshWindowsOrig = round(fileTotalTime / adaptiveThreshWindowLengthOrig);
adaptiveThreshWindowLength = ceil(fileTotalTime / nAdaptiveThreshWindowsOrig); % distribute approximately evenly
adaptiveThreshWindowStartTimes = fileStartTime:adaptiveThreshWindowLength:fileStopTime;
nAdaptiveThreshWindows = numel(adaptiveThreshWindowStartTimes);
fprintf('\nProcessing and thresholding SPKC data in %d windows of length %d seconds.\n', ...
        nAdaptiveThreshWindows, adaptiveThreshWindowLength);

nPreThresholdSamples = 16;
nPostThresholdSamples = 40;
nDeadPostThresholdSamples = 40;
nWaveformSamples = nPreThresholdSamples + nPostThresholdSamples + 1;
t = (-nPreThresholdSamples:nPostThresholdSamples) / Fs * 1000; % ms
numSDsThresh = 4;
isUseMAD = 0;
doUpperThresh = 0;

%% process each SPKC channel in windows
assert(numel(spkcChannelInd) == 1);
channelID = spkcChannelsToRun(spkcChannelInd);
channelName = dataInfo.AnalogChannels{channelID}.Name;
fprintf('\nChannel %s:\n', channelName);

thresholds = nan(nAdaptiveThreshWindows, 1);
extractedWaveforms = cell(nAdaptiveThreshWindows, 1);
startWaveformTs = cell(nAdaptiveThreshWindows, 1);

for k = 1:nAdaptiveThreshWindows
    startTime = adaptiveThreshWindowStartTimes(k);
    endTime = startTime + adaptiveThreshWindowLength - 1/Fs;

    fprintf('\nWindow %d/%d (%d%%): Loading data from channel %s: t = %0.1f s to t = %0.1f s...\n', ...
            k, nAdaptiveThreshWindows, round(k/nAdaptiveThreshWindows*100), channelName, startTime, endTime);

    % PL2AdTimeSpan() uses inclusive endTime
    spkcInfo = PL2AdTimeSpan(pl2FilePath, dataInfo.AnalogChannels{channelID}.Name, startTime, endTime);
    
    if ~isempty(spkcInfo.Values)
        highPassData = padNaNsToAccountForDropsPL2NoIndexing(spkcInfo);
        assert(numel(highPassData) <= round((endTime - startTime) * Fs) + 1);
        spkcInfo.Values = []; % clear
        
        % extract waveforms via thresholding -- just lower threshold for now
        [extractedWaveforms{k},startWaveformInds,thresholds(k)] = findSpikeWaveformsUsingThreshold(...
                highPassData, numSDsThresh, nPreThresholdSamples, nPostThresholdSamples, nDeadPostThresholdSamples, ...
                isUseMAD, doUpperThresh);

        % adjust local index to index into full data for time calculation
        startWaveformTs{k} = (startWaveformInds + round(spkcInfo.FragTs(1) * Fs) - 1) / Fs; % true if start time is 0
        clear highPassData;
    else
        clear spkcInfo;
        fprintf('No data in this window.\n');
        extractedWaveforms{k} = nan(1, nWaveformSamples); % so that cellfun works later
        startWaveformTs{k} = [];
    end
end

%% get means and collapse cell arrays
nWfByWindow = cellfun(@numel, startWaveformTs);
meanExtractedWaveform = cell2mat(cellfun(@(x) mean(x, 1), extractedWaveforms, 'UniformOutput', false));
seExtractedWaveform = cell2mat(cellfun(@(x) std(x, 0, 1), extractedWaveforms, 'UniformOutput', false)) ./ sqrt(nWfByWindow);
wfAll = cell2mat(extractedWaveforms);
wfAll = trimNanRows(wfAll);
tsAll = cell2mat(startWaveformTs);
assert(size(wfAll, 1) == size(tsAll, 1));
fprintf('\n');

%% note putative axonal waveforms
% 1. maximum before threshold crossing
[~,i] = max(wfAll, [], 2);
isPutativeAxon = i < nPreThresholdSamples;
% 2. triphasic waveform
% the max before threshold is within 6 samples of threshold (0.15 ms @
% 40kHz)
% the max after threshold is within 6 samples of threshold
axonMaxPreSamplesToThreshold = 6;
axonMaxPostSamplesToThreshold = 6;
[~,iPre] = max(wfAll(:,1:nPreThresholdSamples), [], 2);
[~,iPost] = max(wfAll(:,end-nPostThresholdSamples:end), [], 2);
isPutativeAxon = isPutativeAxon | ...
        ((nPreThresholdSamples - iPre + 1) <= axonMaxPreSamplesToThreshold & ...
        iPost <= axonMaxPostSamplesToThreshold);
fprintf('%d/%d (%d%%) putative axons\n', sum(isPutativeAxon), numel(tsAll), ...
        round(sum(isPutativeAxon) / numel(tsAll) * 100));

%% plot
plotFileName = sprintf('%s/%s-%s-MUA_stability.png', processedDataRootDir, sessionName, channelName);
plotMUAStability(channelName, tsAll, t, wfAll, meanExtractedWaveform, ...
        seExtractedWaveform, thresholds, nWfByWindow, adaptiveThreshWindowLength, ...
        isPutativeAxon, plotFileName);
close;

%% remove putative axonal waveforms
wf = wfAll(~isPutativeAxon,:);
ts = tsAll(~isPutativeAxon);

%% save MUA to file
thresholdParams = var2struct(adaptiveThreshWindowLength, adaptiveThreshWindowStartTimes, ...
        nPreThresholdSamples, nPostThresholdSamples, ...
        nDeadPostThresholdSamples, nWaveformSamples, t, numSDsThresh, isUseMAD, ...
        doUpperThresh, Fs, thresholds, ...
        axonMaxPreSamplesToThreshold, axonMaxPostSamplesToThreshold);
saveFileName = sprintf('%s/%s-%s-MUA.mat', processedDataRootDir, sessionName, channelName);
save(saveFileName, 'sessionName', 'channelName', 'pl2FileName', ...
        'wf', 'ts', 'wfAll', 'tsAll', 'isPutativeAxon', 'thresholdParams');

fprintf('Done. Elapsed time: %0.1f min\n', toc/60);
