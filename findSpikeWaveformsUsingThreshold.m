function [extractedWaveforms,startWaveformInds,threshold] = findSpikeWaveformsUsingThreshold(...
        data, numSDsThresh, preExtremeSamples, postExtremeSamples, deadSamplesAfterThreshCrossing, ...
        isUseMAD, doUpperThresh)
% Trautmann et al (2017, bioRxiv) uses RMS, which is the same as SDs from 
% the mean

data = makeRowVector(data);

%% compute noise level
% remove waveforms 10 samples pre (0.25 ms @ 40 kHz) and 30 samples post
% (0.75 ms @ 40 kHz) threshold crossings
initNumSDsThresh = 3; % both + and -
initPreExtremeSamples = 10;
initPostExtremeSamples = 30;

isExtremeInit = findDataCrossingThreshold(data, initNumSDsThresh, ...
        initPreExtremeSamples, initPostExtremeSamples, isUseMAD);
dataNotExtremeInit = data(~isExtremeInit);

%% find threshold crossings using above noise level
meanAdjData = nanmean(dataNotExtremeInit);
if isUseMAD % median absolute deviation - more robust than SD
    sdAdjData = mad(dataNotExtremeInit, 1);
else
    sdAdjData = nanstd(dataNotExtremeInit);
end
fprintf('Removed %d/%d (%d%%) data points in noise calculation.\n', sum(isExtremeInit), ...
        numel(data), round(sum(isExtremeInit)/numel(data)*100));
fprintf('Adjusted mean: %0.3f, Adjusted SD: %0.3f\n', meanAdjData, sdAdjData);

if doUpperThresh
    threshold = meanAdjData + numSDsThresh * sdAdjData;
    isExtreme = data > threshold;
else
    threshold = meanAdjData - numSDsThresh * sdAdjData;
    isExtreme = data < threshold;
end

%% extract waveforms around each threshold crossing
% lower and upper waveforms are computed independently
% dead time is not considered across them
% the same waveform might cross both the upper and lower threshold
fprintf('Threshold: %0.3f\n', threshold);
isAlignTrough = 1;
[extractedWaveforms,startWaveformInds] = extractWaveforms(data, isExtreme, ...
        preExtremeSamples, postExtremeSamples, deadSamplesAfterThreshCrossing, isAlignTrough);
