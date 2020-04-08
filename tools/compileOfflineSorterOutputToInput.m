function compileOfflineSorterOutputToInput(processedDataRootDir, sessionName, channelInds)
% create a Plexon Offline Sorter readable .mat file of spike waveforms and 
% times from the generated MUA files for a session

% output file has waveform data in microvolts

% channelInds should be all channel inds of this session
% code does not yet work for selective channels
% TODO adapt to work like createOfflineSorterInput.m

%% read MUA files from individual channels for this session

% The spike waveform data must be contained in a MATLAB cell array of the form
% cellarray[channel]. Within each cell, there must be an array containing the spike
% waveform data for the channel, of the form array[spike][sample]. The number of
% samples in each spike must be identical, but any number of spikes are allowed.
% The values in the array can be interpreted as either microVolts, or as ADC counts.
wfData = cell(max(channelInds), 1);

% Similarly, the timestamps must be contained in a MATLAB cell array the form
% cellarray[channel], where each cell must contain an array timestamps[spike]. The
% number of channels must match between the spikes cell array and the timestamps
% cell array, and also the number of spikes in the within-cell arrays must match
% between the spikes and timestamps arrays for each channel. The timestamp
% values can be interpreted as either Seconds, milliSeconds, or Clock ticks.
tsData = cell(max(channelInds), 1);

% The cell array containing the spike unit designations must be of the form
% cellarray[channel], with each cell containing an array units[spike] of
% integers. The units must correspond 1-to-1 with the spike waveform cell
% array. 0 = unsorted.
% the unit index / id for each waveform
unitIndInChannelData = cell(max(channelInds), 1);
for i = 1:max(channelInds)
    unitIndInChannelData{i} = int16(zeros(0, 1));
end

% also save threshold params for later use
fileName = sprintf('%s/%s-allMUA.mat', processedDataRootDir, sessionName);
fprintf('Reading file: %s\n', fileName);
LTPD = load(fileName, 'thresholdParamsData');

for i = 1:numel(channelInds)
    ci = channelInds(i);
    thresholdParamsData(ci) = LTPD.thresholdParamsData(ci);
    
    fileName = sprintf('%s/%s-SUA_%03d.mat', processedDataRootDir, sessionName, ci-1);
    fprintf('(%d/%d = %d%%) Reading file: %s\n', i, numel(channelInds), round(i / numel(channelInds) * 100), fileName);
    LWF = load(fileName, sprintf('wfData%d', ci-1));
    suaData = LWF.(sprintf('wfData%d', ci-1));
    % suaData should have waveform x data where
    % suaData(:,1) = channel number
    % suaData(:,2) = unit id (0 = unsorted)
    % suaData(:,3) = timestamp in s (time of wf minimum after threshold crossing)
    % suaData(:,4:nSamples+3) = waveform in microvolts
    assert(all(suaData(:,1) == ci));
    
    wfData{ci} = suaData(:,4:end); % save at index ci to keep the channel number
    tsData{ci} = suaData(:,3); % seconds
    unitIndInChannelData{ci} = int16(suaData(:,2));
end

%% save MUA wf, ts data to .mat file for importing in Plexon Offline Sorter
% use Import Waveform Data from MATLAB function

fileAppend = 'sortedSUA';
saveFileName = sprintf('%s/%s-%s.mat', processedDataRootDir, sessionName, fileAppend);
fprintf('Writing compiled MUA waveforms, timestamps, and threshold parameters to file: %s\n', saveFileName);
save(saveFileName, 'wfData', 'tsData', 'thresholdParamsData', 'unitIndInChannelData', '-v7.3');

%% break up offline sorter input into manageable files
breakUpOfflineSorterInput(processedDataRootDir, sessionName, fileAppend, fileAppend);

