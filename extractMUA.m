function extractMUA(processedDataRootDir, dataDirRoot, sessionName, pl2FileName, spkcChannelInd)

%% get PL2 file metadata
pl2FilePath = sprintf('%s/%s/%s', dataDirRoot, sessionName, pl2FileName);
dataInfo = PL2GetFileIndex(pl2FilePath);
Fs = dataInfo.TimestampFrequency;

%% index all the SPKC channels
doesSPKCChannelHaveData = false(numel(dataInfo.AnalogChannels), 1);
fprintf('SPKC channels with data: ');
for i = 1:numel(dataInfo.AnalogChannels)
    if dataInfo.AnalogChannels{i}.Enabled && strcmp(dataInfo.AnalogChannels{i}.SourceName, 'SPKC') && ...
            dataInfo.AnalogChannels{i}.NumValues > 0 && ...
            dataInfo.AnalogChannels{i}.Channel <= 125 % SKIP extra analog signal data
        adInfo = PL2AdTimeSpan(pl2FilePath, dataInfo.AnalogChannels{i}.Name, 0, 0.01);
        if any(adInfo.Values)
            fprintf('%d ', i);
            doesSPKCChannelHaveData(i) = 1;
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
adaptiveThreshWindowLength = ceil(fileTotalTime / nAdaptiveThreshWindowsOrig);
adaptiveThreshWindowStartTimes = fileStartTime:adaptiveThreshWindowLength:fileStopTime;
nAdaptiveThreshWindows = numel(adaptiveThreshWindowStartTimes);

nPreThresholdSamples = 16;
nPostThresholdSamples = 40;
nDeadPostThresholdSamples = 40;
nWaveformSamples = nPreThresholdSamples + nPostThresholdSamples + 1;
t = (-nPreThresholdSamples:nPostThresholdSamples) / Fs * 1000; % ms
numSDsThresh = 4;
isUseMAD = 0;
doUpperThresh = 0;

%% process each SPKC channel in windows
channelID = spkcChannelsToRun(spkcChannelInd);
channelName = dataInfo.AnalogChannels{channelID}.Name;
% fprintf('\nChannel %s (%d/%d = %d%%):\n', channelName, i, numel(spkcChannelsToRun), round(i/numel(spkcChannelsToRun)*100));
fprintf('\nChannel %s:\n', channelName);

thresholds = nan(nAdaptiveThreshWindows, 1);
extractedWaveforms = cell(nAdaptiveThreshWindows, 1);
startWaveformInds = cell(nAdaptiveThreshWindows, 1);

for k = 1:nAdaptiveThreshWindows
    startTime = adaptiveThreshWindowStartTimes(k);
    endTime = startTime + adaptiveThreshWindowLength;

    fprintf('\nWindow %d/%d (%d%%): Loading data from channel %s: t = %0.1f s to t = %0.1f s...\n', ...
            k, nAdaptiveThreshWindows, round(k/nAdaptiveThreshWindows*100), channelName, startTime, endTime);
    % TODO unclear whether PL2AdTimeSpan() uses inclusive endTime
    spkcInfo = PL2AdTimeSpan(pl2FilePath, dataInfo.AnalogChannels{channelID}.Name, startTime, endTime);
    highPassData = spkcInfo.Values;
    clear spkcInfo;

    if ~isempty(highPassData)
        % extract waveforms via thresholding -- just lower threshold for now
        [extractedWaveforms{k},startWaveformInds{k},thresholds(k)] = findSpikeWaveformsUsingThreshold(...
                highPassData, numSDsThresh, nPreThresholdSamples, nPostThresholdSamples, nDeadPostThresholdSamples, ...
                isUseMAD, doUpperThresh);

        % adjust index for full data
        startWaveformInds{k} = startWaveformInds{k} + round(startTime * Fs) + 1; % true if start time is 0
    else
        extractedWaveforms{k} = nan(1, nWaveformSamples); % so that cellfun works later
    end
end

%% get means and collapse cell arrays
nWfByWindow = cellfun(@numel, startWaveformInds);
meanExtractedWaveform = cell2mat(cellfun(@(x) mean(x, 1), extractedWaveforms, 'UniformOutput', false));
seExtractedWaveform = cell2mat(cellfun(@(x) std(x, 0, 1), extractedWaveforms, 'UniformOutput', false)) ./ sqrt(nWfByWindow);
wf = cell2mat(extractedWaveforms);
wf = trimNanRows(wf);
ts = cell2mat(startWaveformInds) / Fs;
assert(size(wf, 1) == size(ts, 1));
fprintf('\n');

%% plot
plotFileName = sprintf('%s/%s-%s-extractedMUA.png', processedDataRootDir, sessionName, channelName);
plotMUAStability(channelName, t, wf, meanExtractedWaveform, ...
        seExtractedWaveform, thresholds, nWfByWindow, adaptiveThreshWindowLengthOrig, ...
        plotFileName)

close;

%% save MUA to file
thresholdParams = var2struct(adaptiveThreshWindowLengthOrig, adaptiveThreshWindowStartTimes, ...
        nPreThresholdSamples, nPostThresholdSamples, ...
        nDeadPostThresholdSamples, nWaveformSamples, t, numSDsThresh, isUseMAD, ...
        doUpperThresh, Fs, thresholds);
saveFileName = sprintf('%s/%s-%s-MUA.mat', processedDataRootDir, sessionName, channelName);
save(saveFileName, 'sessionName', 'channelName', 'pl2FileName', ...
        'wf', 'ts', 'thresholdParams');

