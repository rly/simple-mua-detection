function createOfflineSorterInput(processedDataRootDir, sessionName, channelInds)
% Create a .mat file containing spike waveforms and times from the generated MUA files for a session

% This file can be opened by Plexon Offline Sorter v4 under File > Import > Spike Data from MATLAB.
% The MATLAB Waveform Cell Array Name is "wfData" and the Voltage Units is "microVolts".
% The MATLAB Timestamp Cell Array Name is "tsData" and the Time Units is "seconds".
% The digitizing frequency and maximum voltage should be set according to the input data.
% The MATLAB Units Cell Array Name is "unitIndInChannelData".

%% read MUA files from individual channels for this session
% The spike waveform data must be contained in a MATLAB cell array of the form
% cellarray[channel]. Within each cell, there must be an array containing the spike
% waveform data for the channel, of the form array[spike][sample]. The number of
% samples in each spike must be identical, but any number of spikes are allowed.
% The values in the array can be interpreted as either microVolts, or as ADC counts.
wfData = {};

% Similarly, the timestamps must be contained in a MATLAB cell array the form
% cellarray[channel], where each cell must contain an array timestamps[spike]. The
% number of channels must match between the spikes cell array and the timestamps
% cell array, and also the number of spikes in the within-cell arrays must match
% between the spikes and timestamps arrays for each channel. The timestamp
% values can be interpreted as either Seconds, milliSeconds, or Clock ticks.
tsData = {};

% The cell array containing the spike unit designations must be of the form
% cellarray[channel], with each cell containing an array units[spike] of
% 16-bit integers. The units must correspond 1-to-1 with the spike waveform cell
% array. 0 = unsorted.
unitIndInChannelData = {};

% break up compiled MUA data into groups of 16 channels because offline sorter cannot handle massive .mat files 
saveChGroups = [[1 16]; [17 32]; [33 48]; [49 64]; [65 80]; [81 96]];

for i = 1:size(saveChGroups, 1)
    startCh = saveChGroups(i,1);
    endCh = saveChGroups(i,2);
    if startCh > max(channelInds)
        break
    end
    
    % preallocate more cells
    wfData(startCh:endCh, 1) = {0};
    tsData(startCh:endCh, 1) = {0};
    unitIndInChannelData(startCh:endCh, 1) = {int16(0)};
    
    % load data from each channel into vars
    for j = startCh:endCh
        ci = channelInds(j);
        fileName = sprintf('%s/%s-SPKC%03d-MUA.mat', processedDataRootDir, sessionName, ci);
        fprintf('%d/%d (%d%%), ch %d: %s\n', j, numel(channelInds), round(j / numel(channelInds) * 100), ci, fileName);
        L = load(fileName, 'wfAll', 'tsAll', 'isPutativeAxon', 'thresholdParams');
        wfData{ci} = L.wfAll * 1000; % save at index ci to keep the channel number, x1000 to convert mV to uV
        tsData{ci} = L.tsAll; % seconds
        unitIndInChannelData{ci} = int16(~L.isPutativeAxon); % designate putative axonal wfs as 0, others as 1
        thresholdParamsData(ci) = L.thresholdParams; %#ok<AGROW>
    end
    
    % write vars to file
    saveFileName = sprintf('%s/%s-wfAll-%d-%d.mat', processedDataRootDir, sessionName, startCh, endCh);
    fprintf('Writing to file: %s\n', saveFileName);
    save(saveFileName, 'wfData', 'tsData', 'unitIndInChannelData', 'thresholdParamsData', '-v7.3');
    
    % sanity check
    nSamples = [thresholdParamsData.nWaveformSamples];
    assert(all(nSamples == nSamples(1)));
    
    % zero out the just written channels, maintaining matrix sizes, before writing the next channel group
    wfData(startCh:endCh) = {zeros(0, nSamples(1))};
    tsData(startCh:endCh) = {zeros(0, 1)};
    unitIndInChannelData(startCh:endCh) = {int16(zeros(0, 1))};
    % OK to keep thresholdParamsData across groups - it's small and zeroing out structs is hard
end
