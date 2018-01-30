function isExtreme = findDataCrossingThreshold(data, numSDsThresh, ...
        preExtremeSamples, postExtremeSamples, isUseMAD)
% returns logical vector where the element is true if the corresponding
% data point is either preExtremeSamples prior to an extreme data point or
% postExtremeSamples after an extreme data point, as defined by
% numSDsThresh standard deviations away from the mean, regardless of
% positive or negative direction. in other words, each extreme data point
% creates a segment of true values in the isExtreme vector with
% preExtremeSamples prior and postExtremeSamples after the data point.

data = makeRowVector(data);

% compute noise level
meanData = nanmean(data);
if isUseMAD % median absolute deviation - more robust than SD
    sdData = mad(data, 1);
else
    sdData = nanstd(data);
end

lowerThresh = meanData - numSDsThresh * sdData;
upperThresh = meanData + numSDsThresh * sdData;

extremeInds = find(data < lowerThresh | data > upperThresh);
isExtreme = false(size(data));
for i = 1:numel(extremeInds)
    lb = max(1, extremeInds(i) - preExtremeSamples); % keep inds within range
    ub = min(numel(data), extremeInds(i) + postExtremeSamples);
    isExtreme(lb:ub) = true;
end

