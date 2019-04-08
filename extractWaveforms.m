function [extractedWaveforms,startWaveformInds] = extractWaveforms(data, ...
        isOutsideThresh, preExtremeSamples, postExtremeSamples, ...
        deadSamplesAfterThreshCrossing, doUpperThresh)
% Extract and align spike waveforms, with dead zone after a threshold 
% crossing
% 
% Inputs:
% - data:               N x 1 vector of high-pass filtered data
% - isOutsideThresh:    N x 1 logical vector indicating whether the
%                       corresponding value in data was above/below 
%                       threshold
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
% - doUpperThresh:      whether the threshold is above or below zero, which
%                       determines whether to align the waveforms to the
%                       peak or trough
% 
% Outputs:
% - extractedWaveforms: M x T matrix where each row is a waveform, columns 
%                       are samples
% - startWaveformInds:  M x 1 vector indicating where in data is the first
%                       element of the corresponding extracted waveform
%
% Written by Ryan Ly, Kastner Lab, Princeton University

assert(all(size(data) == size(isOutsideThresh)));

% number of samples pre and post threshold crossing to look for extreme
% (trough or peak) for alignment
alignToExtremeMaxShiftPreThreshSamples = 0;
alignToExtremeMaxShiftPostThreshSamples = 40; % 1 ms @ 40 kHz

% threshold crossing is when data goes from non-extreme to extreme (0 -> 1)
diffIsExtreme = diff(isOutsideThresh);
threshCrossing = find(diffIsExtreme == 1) + 1; % +1 to capture the extreme not the pre-extreme
clear diffIsExtreme;

nThreshCrossing = numel(threshCrossing);
fprintf('\tFound %d threshold crossings, ', nThreshCrossing);

isGoodThreshCrossing = true(nThreshCrossing, 1);
extractedWaveforms = nan(nThreshCrossing, preExtremeSamples + postExtremeSamples + 1);
startWaveformInds = nan(nThreshCrossing, 1);
for i = 1:nThreshCrossing
    % process only threshold crossings that are not too close to earlier 
    % ones, as detected below
    if isGoodThreshCrossing(i)
        % disable any threshold crossings too close after this one
        diffThreshCrossingWithThis = threshCrossing - threshCrossing(i);
        isThreshCrossingTooCloseToThis = diffThreshCrossingWithThis > 0 & ...
                diffThreshCrossingWithThis <= deadSamplesAfterThreshCrossing;
        isGoodThreshCrossing(isThreshCrossingTooCloseToThis) = false;
        
        % extract data around the threshold crossing to search for
        % the extreme for alignment
        lb = threshCrossing(i) - alignToExtremeMaxShiftPreThreshSamples;
        ub = threshCrossing(i) + alignToExtremeMaxShiftPostThreshSamples;
        % skip this threshold crossing if extracted waveform would extend
        % past data boundaries
        if lb < 1 || ub > numel(data)
            continue; 
        end
        extractedSampleWaveform = data(lb:ub);
        
        % if threshold is below 0, find the trough, else find the peak
        if ~doUpperThresh
            [~,extremeInd] = min(extractedSampleWaveform);
        else
            [~,extremeInd] = max(extractedSampleWaveform);
        end
        % get the index of the extreme relative to data
        extremeGlobalInd = threshCrossing(i) - alignToExtremeMaxShiftPreThreshSamples + extremeInd - 1;
        
        % extract waveform 
        lb = extremeGlobalInd - preExtremeSamples;
        ub = extremeGlobalInd + postExtremeSamples;
        % skip this threshold crossing if extracted waveform would extend
        % past data boundaries
        if lb < 1 || ub > numel(data)
            continue;
        end
        extractedWaveforms(i,:) = data(lb:ub);
        % save index of the first element of the waveform within data
        startWaveformInds(i) = lb; 
    end
end

% remove waveforms with NaN anywhere in it
[extractedWaveforms,rowsRemoved] = trimAnyNanRows(extractedWaveforms);
startWaveformInds(rowsRemoved) = [];

fprintf('extracted %d waveforms.\n', size(extractedWaveforms, 1));
