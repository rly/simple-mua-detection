function isExtreme = findDataCrossingThreshold(data, numSDsThresh, ...
        preExtremeSamples, postExtremeSamples, isUseMAD)
% Label the data that is more than x SDs away from the mean with a pre- and
% post-extreme value buffer
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
% 
% Outputs: 
% - isExtreme:          N x 1 logical vector indicating whether the
%                       corresponding value in data was above or below 
%                       threshold (considers both), or is 
%                       preExtremeSamples prior to an extreme data point or
%                       postExtremeSamples after an extreme data point. in 
%                       other words, each extreme data point creates a 
%                       segment of true values in the isExtreme vector with
%                       preExtremeSamples prior and postExtremeSamples 
%                       after the data point

data = makeRowVector(data);

% compute mean and noise level
meanData = nanmean(data);
if isUseMAD 
    % median absolute deviation - more robust than SD
    sdData = mad(data, 1);
else
    sdData = nanstd(data);
end

lowerThresh = meanData - numSDsThresh * sdData;
upperThresh = meanData + numSDsThresh * sdData;

extremeInds = find(data < lowerThresh | data > upperThresh);

% mark data points as extreme around the points that are above the upper
% threshold or below the lower threshold
isExtreme = false(size(data));
for i = 1:numel(extremeInds)
    lb = max(1, extremeInds(i) - preExtremeSamples); % keep inds within range
    ub = min(numel(data), extremeInds(i) + postExtremeSamples);
    isExtreme(lb:ub) = true;
end

