function breakUpOfflineSorterInput(muaDataDir, sessionName, fileInAppend, fileOutAppend)
% break up compiled MUA data into groups of 16 channels because plexon offline sorter cannot handle massive .mat files 

fileName = sprintf('%s/%s-%s.mat', muaDataDir, sessionName, fileInAppend);
L = load(fileName);
thresholdParamsData = L.thresholdParamsData; % full struct is resaved in each .mat file

outFileNameBase = sprintf('%s/%s', muaDataDir, sessionName);
nSamples = [thresholdParamsData.nWaveformSamples];
assert(all(nSamples == nSamples(1)));
nSamples = nSamples(1);
maxChannels = numel(L.tsData);

% save 1-16, remove data from other channels from struct M
M = L;
M.tsData(17:end) = [];
M.wfData(17:end) = [];
M.unitIndInChannelData(17:end) = [];
outFileName = sprintf('%s-%s-%d-%d.mat', outFileNameBase, fileOutAppend, 1, 16);
saveData(M, outFileName);

% save 17-32, remove data from other channels from struct M
M = L;
for i = 1:16
    M.tsData{i} = zeros(0, 1);
    M.wfData{i} = zeros(0, nSamples);
    M.unitIndInChannelData{i} = int16(zeros(0, 1));
end
if maxChannels > 32
    M.tsData(33:end) = [];
    M.wfData(33:end) = [];
    M.unitIndInChannelData(33:end) = [];
end
outFileName = sprintf('%s-%s-%d-%d.mat', outFileNameBase, fileOutAppend, 17, 32);
saveData(M, outFileName);

if maxChannels > 32
    % save 33-48, remove data from other channels from struct M
    M = L;
    for i = 1:32
        M.tsData{i} = zeros(0, 1);
        M.wfData{i} = zeros(0, nSamples);
        M.unitIndInChannelData{i} = int16(zeros(0, 1));
    end
    M.tsData(49:end) = [];
    M.wfData(49:end) = [];
    M.unitIndInChannelData(49:end) = [];
    outFileName = sprintf('%s-%s-%d-%d.mat', outFileNameBase, fileOutAppend, 33, 48);
    saveData(M, outFileName);

    % save 49-64, remove data from other channels from struct M
    M = L;
    for i = 1:48
        M.tsData{i} = zeros(0, 1);
        M.wfData{i} = zeros(0, nSamples);
        M.unitIndInChannelData{i} = int16(zeros(0, 1));
    end
    if maxChannels > 64
        M.tsData(65:end) = [];
        M.wfData(65:end) = [];
        M.unitIndInChannelData(65:end) = [];
    end
    outFileName = sprintf('%s-%s-%d-%d.mat', outFileNameBase, fileOutAppend, 49, 64);
    saveData(M, outFileName);
end

if maxChannels > 64
    % save 65-80, remove data from other channels from struct M
    M = L;
    for i = 1:64
        M.tsData{i} = zeros(0, 1);
        M.wfData{i} = zeros(0, nSamples);
        M.unitIndInChannelData{i} = int16(zeros(0, 1));
    end
    M.tsData(81:end) = [];
    M.wfData(81:end) = [];
    M.unitIndInChannelData(81:end) = [];
    outFileName = sprintf('%s-%s-%d-%d.mat', outFileNameBase, fileOutAppend, 65, 80);
    saveData(M, outFileName);

    % save 81:96, remove data from other channels from struct M
    M = L;
    for i = 1:80
        M.tsData{i} = zeros(0, 1);
        M.wfData{i} = zeros(0, nSamples);
        M.unitIndInChannelData{i} = int16(zeros(0, 1));
    end
    outFileName = sprintf('%s-%s-%d-%d.mat', outFileNameBase, fileOutAppend, 81, 96);
    saveData(M, outFileName);
end

function saveData(M, outFileName)
    tsData = M.tsData; %#ok<NASGU>
    wfData = M.wfData; %#ok<NASGU>
    unitIndInChannelData = M.unitIndInChannelData; %#ok<NASGU>
    thresholdParamsData = M.thresholdParamsData; %#ok<NASGU>
    save(outFileName, 'tsData', 'wfData', 'unitIndInChannelData', 'thresholdParamsData', '-v7.3');
    fprintf('Saved to file %s.\n', outFileName);

