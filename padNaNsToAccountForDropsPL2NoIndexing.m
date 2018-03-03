function adAdj = padNaNsToAccountForDropsPL2NoIndexing(adInfo)
% adds NaNs into AD values when no data was recorded, e.g. due to drops or
% pauses
% unlike padNaNsToAccountForDropsPL2(), this does not adjust the indexing
% of the first value so that index t * Fs = index into the returned adAdj
% just fills in the middle gaps with NaNs. doesn't move the first value 

% adInfo is a struct with fields:
% adInfo.Values - all values recorded -- all fragments concatenated, row
% vector
% adInfo.FragTs - timestamps of the start of each fragment, column vector
% adInfo.FragCounts - number of values in each fragment, column vector
% adInfo.ADFreq - sampling frequency, scalar

% returns column vector 

assert(size(adInfo.FragTs, 2) == 1);
assert(all(size(adInfo.FragTs) == size(adInfo.FragCounts)));
assert(sum(adInfo.FragCounts) == numel(adInfo.Values));

% adInfo.FragTs(1) is the offset of the first block from the start of
% recording. ignore that offset here
finalLength = round((adInfo.FragTs(end) - adInfo.FragTs(1)) * adInfo.ADFreq) + adInfo.FragCounts(end);
adAdj = nan(finalLength, 1);
fprintf('Padding AD signal to account for recording drops: %d -> %d\n', ...
        numel(adInfo.Values), finalLength);

% the start/end index of each fragment in Values
endBlockIndex = cumsum(adInfo.FragCounts);
startBlockIndex = [1; endBlockIndex(1:end-1)+1];

for i = 1:numel(adInfo.FragTs)
    newStartBlockIndex = round((adInfo.FragTs(i) - adInfo.FragTs(1)) * adInfo.ADFreq) + 1;
    numValuesInBlock = adInfo.FragCounts(i);
    adAdj(newStartBlockIndex:newStartBlockIndex+numValuesInBlock-1) = adInfo.Values(startBlockIndex(i):endBlockIndex(i));
end

