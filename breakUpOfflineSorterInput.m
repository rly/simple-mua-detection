function breakUpOfflineSorterInput(muaDataDir, sessionName, fileInAppend, fileOutAppend)

% for splitting 32 or 64 channel data for offline sorter
% because offline sorter cannot handle massive .mat files 
addpath('util');

fileName = sprintf('%s/%s-%s.mat', muaDataDir, sessionName, fileInAppend);
L = load(fileName);
thresholdParamsData = L.thresholdParamsData; % resaved in each .mat file

outFileNameBase = sprintf('%s/%s', muaDataDir, sessionName);
nSamples = size(L.wfData{1}, 2);
maxChannels = numel(L.tsData);

% split into groups of 16
if maxChannels == 64
    % save 1-16
    M = L;
    M.tsData(17:64) = [];
    M.wfData(17:64) = [];
    M.unitIndInChannelData(17:64) = [];
    tsData = M.tsData;
    wfData = M.wfData;
    unitIndInChannelData = M.unitIndInChannelData;
    outFileName = sprintf('%s-%s-%d-%d.mat', outFileNameBase, fileOutAppend, 1, 16);
    save(outFileName, 'tsData', 'wfData', 'unitIndInChannelData', 'thresholdParamsData', '-v7.3');
    fprintf('Saved to file %s.\n', outFileName);

    % save 17-32
    M = L;
    for i = 1:16
        M.tsData{i} = zeros(0, 1);
        M.wfData{i} = zeros(0, nSamples);
        M.unitIndInChannelData{i} = zeros(0, 1);
    end
    M.tsData(33:64) = [];
    M.wfData(33:64) = [];
    M.unitIndInChannelData(33:64) = [];
    tsData = M.tsData;
    wfData = M.wfData;
    unitIndInChannelData = M.unitIndInChannelData;
    outFileName = sprintf('%s-%s-%d-%d.mat', outFileNameBase, fileOutAppend, 17, 32);
    save(outFileName, 'tsData', 'wfData', 'unitIndInChannelData', 'thresholdParamsData', '-v7.3');
    fprintf('Saved to file %s.\n', outFileName);

    % save 33-48
    M = L;
    for i = 1:32
        M.tsData{i} = zeros(0, 1);
        M.wfData{i} = zeros(0, nSamples);
        M.unitIndInChannelData{i} = zeros(0, 1);
    end
    M.tsData(49:64) = [];
    M.wfData(49:64) = [];
    M.unitIndInChannelData(49:64) = [];
    tsData = M.tsData;
    wfData = M.wfData;
    unitIndInChannelData = M.unitIndInChannelData;
    outFileName = sprintf('%s-%s-%d-%d.mat', outFileNameBase, fileOutAppend, 33, 48);
    save(outFileName, 'tsData', 'wfData', 'unitIndInChannelData', 'thresholdParamsData', '-v7.3');
    fprintf('Saved to file %s.\n', outFileName);

    % save 49-64
    M = L;
    for i = 1:48
        M.tsData{i} = zeros(0, 1);
        M.wfData{i} = zeros(0, nSamples);
        M.unitIndInChannelData{i} = zeros(0, 1);
    end
    tsData = M.tsData;
    wfData = M.wfData;
    unitIndInChannelData = M.unitIndInChannelData;
    outFileName = sprintf('%s-%s-%d-%d.mat', outFileNameBase, fileOutAppend, 49, 64);
    save(outFileName, 'tsData', 'wfData', 'unitIndInChannelData', 'thresholdParamsData', '-v7.3');
    fprintf('Saved to file %s.\n', outFileName);

elseif maxChannels == 32
    % save 1-16
    M = L;
    M.tsData(17:32) = [];
    M.wfData(17:32) = [];
    M.unitIndInChannelData(17:32) = [];
    tsData = M.tsData;
    wfData = M.wfData;
    unitIndInChannelData = M.unitIndInChannelData;
    outFileName = sprintf('%s-%s-%d-%d.mat', outFileNameBase, fileOutAppend, 1, 16);
    save(outFileName, 'tsData', 'wfData', 'unitIndInChannelData', 'thresholdParamsData', '-v7.3');
    fprintf('Saved to file %s.\n', outFileName);

    % save 17-32
    M = L;
    for i = 1:16
        M.tsData{i} = zeros(0, 1);
        M.wfData{i} = zeros(0, nSamples);
        M.unitIndInChannelData{i} = zeros(0, 1);
    end
    tsData = M.tsData;
    wfData = M.wfData;
    unitIndInChannelData = M.unitIndInChannelData;
    outFileName = sprintf('%s-%s-%d-%d.mat', outFileNameBase, fileOutAppend, 17, 32);
    save(outFileName, 'tsData', 'wfData', 'unitIndInChannelData', 'thresholdParamsData', '-v7.3');
    fprintf('Saved to file %s.\n', outFileName);
    
end
