function [extractedWaveforms,startWaveformInds,threshold] = findSpikeWaveformsUsingThreshold(...
        data, numSDsThresh, preExtremeSamples, postExtremeSamples, ...
        deadSamplesAfterThreshCrossing, isUseMAD, doUpperThresh)
% Extract and align spike waveforms using a specified threshold
% 
% Inputs:
% - data:               N x 1 vector of high-pass filtered data
% - numSDsThresh:       number of SDs away from the mean to consider the
%                       data an extreme value, i.e. part of a spike
% - preExtremeSamples:  number of samples to extract prior to the extremal
%                       value (trough/peak) corresponding to the threshold 
%                       crossing
% - postExtremeSamples: number of samples to extract after the extremal
%                       value (trough/peak) corresponding to the threshold 
%                       crossing
% - deadSamplesAfterThreshCrossing: number of samples after the threshold
%                                   crossing to disallow to be considered
%                                   for another threshold crossing. this
%                                   prevents two threshold crossings from
%                                   occuring within a reasonable refractory
%                                   period (usually about 1 ms). 
% - isUseMAD:           whether to use median absolute deviation method,
%                       which is more robust than the standard deviation 
%                       method (see Quian Quiroga et al., 2004)
% - doUpperThresh:      whether the threshold is above or below zero, which
%                       determines whether to align the waveforms to the
%                       peak or trough
% 
% Outputs:
% - extractedWaveforms: M x T matrix where each row is a waveform, columns 
%                       are samples
% - startWaveformInds:  M x 1 vector indicating where in data is the first
%                       element of the corresponding extracted waveform
% - threshold:          value of threshold for detecting spikes
% 
% Written by Ryan Ly, Kastner Lab, Princeton University

data = makeRowVector(data);

%% find and remove spikes using lenient threshold
% remove 10 samples pre- and 30 samples post-threshold crossings
% (0.25 ms pre- and 0.75 ms post-threshold @ 40 kHz) 
initNumSDsThresh = 3; % both + and -
initPreExtremeSamples = 10;
initPostExtremeSamples = 30;

isExtremeInit = findDataCrossingThreshold(data, initNumSDsThresh, ...
        initPreExtremeSamples, initPostExtremeSamples, isUseMAD);
dataNotExtremeInit = data(~isExtremeInit);

%% set mean and sd of data without spikes (more stable than including spikes)
meanAdjData = nanmean(dataNotExtremeInit);
if isUseMAD
    % median absolute deviation
    sdAdjData = mad(dataNotExtremeInit / 0.6745, 1);
else
    sdAdjData = nanstd(dataNotExtremeInit);
end

%% set threshold and find extreme values in data
if doUpperThresh
    threshold = meanAdjData + numSDsThresh * sdAdjData;
    isExtreme = data > threshold;
else
    threshold = meanAdjData - numSDsThresh * sdAdjData;
    isExtreme = data < threshold;
end

%% extract waveforms around each threshold crossing
[extractedWaveforms,startWaveformInds] = extractWaveforms(data, isExtreme, ...
        preExtremeSamples, postExtremeSamples, deadSamplesAfterThreshCrossing, ...
        doUpperThresh);
