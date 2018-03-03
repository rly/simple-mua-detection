function [extractedWaveforms,startWaveformInds] = extractWaveforms(data, isExtreme, preExtremeSamples, ...
        postExtremeSamples, deadSamplesAfterThreshCrossing, isAlignTrough)
% alignTrough - whether to re-align the waveforms based on the minimum
% in the extracted waveform up to the allowed max shift specified below

% extractedWaveforms: each row is a waveform, columns are samples
assert(all(size(data) == size(isExtreme)));

alignToExtremeMaxShiftPreThreshSamples = 0;
alignToExtremeMaxShiftPostThreshSamples = 10;

% threshold crossing is when data goes from non-extreme to extreme (0 -> 1)
diffIsExtreme = diff(isExtreme);
threshCrossing = find(diffIsExtreme == 1) + 1; % +1 to capture the extreme not the pre-extreme
clear diffIsExtreme;

nThreshCrossing = numel(threshCrossing);
fprintf('\tFound %d threshold crossings, ', nThreshCrossing);

isGoodThreshCrossing = true(nThreshCrossing, 1);
extractedWaveforms = nan(nThreshCrossing, preExtremeSamples + postExtremeSamples + 1);
startWaveformInds = nan(nThreshCrossing, 1);
for i = 1:nThreshCrossing
    if isGoodThreshCrossing(i)
        % disable any threshold crossings within deadSamplesAfterThreshCrossing after this one
        diffThreshCrossingWithThis = threshCrossing - threshCrossing(i);
        isGoodThreshCrossing(diffThreshCrossingWithThis > 0 & diffThreshCrossingWithThis <= deadSamplesAfterThreshCrossing) = false;
        
        % find trough within sample, up to alignToExtremeMaxShift away
        lb = threshCrossing(i) - alignToExtremeMaxShiftPreThreshSamples;
        ub = threshCrossing(i) + alignToExtremeMaxShiftPostThreshSamples;
        if lb < 1 || ub > numel(data)
            continue; % skip if the waveform extends past data boundaries
        end
        extractedSampleWaveform = data(lb:ub);
        
        if isAlignTrough
            [~,extremeInd] = min(extractedSampleWaveform);
        else
            [~,extremeInd] = max(extractedSampleWaveform);
        end
        extremeGlobalInd = threshCrossing(i) - alignToExtremeMaxShiftPreThreshSamples + extremeInd - 1;
        
        lb = extremeGlobalInd - preExtremeSamples;
        ub = extremeGlobalInd + postExtremeSamples;
        if lb < 1 || ub > numel(data)
            continue; % skip if the waveform extends past data boundaries
        end
        extractedWaveforms(i,:) = data(lb:ub); % the full waveform
        startWaveformInds(i) = lb; % index of the first element of the 
        % waveform within data
    end
end

extractedWaveforms = trimNanRows(extractedWaveforms);
startWaveformInds = trimNanRows(startWaveformInds);
fprintf('extracted %d waveforms.\n', size(extractedWaveforms, 1));
