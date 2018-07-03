function breakUpOfflineSorterInput(muaDataDir, sessionName)

% for splitting 64 channel data for offline sorter
% because offline sorter cannot handle massive .mat files 
addpath('util');

% sessionName = 'M20170324';
% muaDataDir = 'C:\Users\Ryan\Documents\MATLAB\gratings-task-data\MUA\';
fileName = sprintf('%s/%s-allMUA.mat', muaDataDir, sessionName);
L = load(fileName);
thresholdParamsData = L.thresholdParamsData;

outFileNameBase = sprintf('%s/%s', muaDataDir, sessionName);
nSamples = size(L.wfData{1}, 2);
maxChannels = numel(L.tsData);
% split into groups of 16

if maxChannels == 64
    % save 1-16
    M = L;
    M.tsData(17:64) = [];
    M.wfData(17:64) = [];
    tsData = M.tsData;
    wfData = M.wfData;
    outFileName = sprintf('%s-MUA-%d-%d.mat', outFileNameBase, 1, 16);
    save(outFileName, 'tsData', 'wfData', 'thresholdParamsData', '-v7.3');
    fprintf('Saved to file %s.\n', outFileName);

    % save 17-32
    M = L;
    for i = 1:16
        M.tsData{i} = zeros(0, 1);
        M.wfData{i} = zeros(0, nSamples);
    end
    M.tsData(33:64) = [];
    M.wfData(33:64) = [];
    tsData = M.tsData;
    wfData = M.wfData;
    outFileName = sprintf('%s-MUA-%d-%d.mat', outFileNameBase, 17, 32);
    save(outFileName, 'tsData', 'wfData', 'thresholdParamsData', '-v7.3');
    fprintf('Saved to file %s.\n', outFileName);

    % save 33-48
    M = L;
    for i = 1:32
        M.tsData{i} = zeros(0, 1);
        M.wfData{i} = zeros(0, nSamples);
    end
    M.tsData(49:64) = [];
    M.wfData(49:64) = [];
    tsData = M.tsData;
    wfData = M.wfData;
    outFileName = sprintf('%s-MUA-%d-%d.mat', outFileNameBase, 33, 48);
    save(outFileName, 'tsData', 'wfData', 'thresholdParamsData', '-v7.3');
    fprintf('Saved to file %s.\n', outFileName);

    % save 49-64
    M = L;
    for i = 1:48
        M.tsData{i} = zeros(0, 1);
        M.wfData{i} = zeros(0, nSamples);
    end
    tsData = M.tsData;
    wfData = M.wfData;
    outFileName = sprintf('%s-MUA-%d-%d.mat', outFileNameBase,  49, 64);
    save(outFileName, 'tsData', 'wfData', 'thresholdParamsData', '-v7.3');
    fprintf('Saved to file %s.\n', outFileName);

elseif maxChannels == 32
    % save 1-16
    M = L;
    M.tsData(17:32) = [];
    M.wfData(17:32) = [];
    tsData = M.tsData;
    wfData = M.wfData;
    outFileName = sprintf('%s-MUA-%d-%d.mat', outFileNameBase, 1, 16);
    save(outFileName, 'tsData', 'wfData', 'thresholdParamsData', '-v7.3');
    fprintf('Saved to file %s.\n', outFileName);

    % save 17-32
    M = L;
    for i = 1:16
        M.tsData{i} = zeros(0, 1);
        M.wfData{i} = zeros(0, nSamples);
    end
    tsData = M.tsData;
    wfData = M.wfData;
    outFileName = sprintf('%s-MUA-%d-%d.mat', outFileNameBase, 17, 32);
    save(outFileName, 'tsData', 'wfData', 'thresholdParamsData', '-v7.3');
    fprintf('Saved to file %s.\n', outFileName);
    
end
