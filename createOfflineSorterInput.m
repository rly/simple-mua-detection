function createOfflineSorterInput(processedDataRootDir, sessionName, channelInds)
% create a Plexon Offline Sorter readable .mat file of spike waveforms and 
% times from the generated MUA files for a session

% output file has waveform data in microvolts

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

% also save threshold params for later use

for i = 1:numel(channelInds)
    ci = channelInds(i);
    fileName = sprintf('%s/%s-SPKC%03d-MUA.mat', processedDataRootDir, sessionName, ci);
    fprintf('(%d/%d = %d%%) Reading file: %s\n', i, numel(channelInds), round(i / numel(channelInds) * 100), fileName);
    L = load(fileName);
    wfData{ci} = L.wf * 1000; % save at index ci to keep the channel number, x1000 to convert mV to uV
    tsData{ci} = L.ts;
    
    thresholdParamsData(ci) = L.thresholdParams;
end

%% save MUA wf, ts data to .mat file for importing in Plexon Offline Sorter
% use Import Waveform Data from MATLAB function

saveFileName = sprintf('%s/%s-allMUA.mat', processedDataRootDir, sessionName);
fprintf('Writing compiled MUA waveforms, timestamps, and threshold parameters to file: %s\n', saveFileName);
save(saveFileName, 'wfData', 'tsData', 'thresholdParamsData', '-v7.3');

