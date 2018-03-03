function adAdj = padNaNsToAccountForDropsPL2(adInfo)
% adds NaNs into AD values when no data was recorded, e.g. due to drops or
% pauses, so that index t * Fs = index into the returned adAdj
% if the first fragment / first data recorded is at t=0.000025 at 40 kHz, 
% then no NaNs are added at the start of adAdj. if the first data recorded
% is at t = 0.000050 at 40 kHz, then one NaN is added at the start of
% adAdj. this is a really easy way to index into the AD variable, provided
% that there is not a massive gap between blocks.

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

finalLength = round(adInfo.FragTs(end) * adInfo.ADFreq) + adInfo.FragCounts(end) - 1;
adAdj = nan(finalLength, 1);

% the start/end index of each fragment in Values
endBlockIndex = cumsum(adInfo.FragCounts);
startBlockIndex = [1; endBlockIndex(1:end-1)+1];

for i = 1:numel(adInfo.FragTs)
    newStartBlockIndex = round(adInfo.FragTs(i) * adInfo.ADFreq);
    numValuesInBlock = adInfo.FragCounts(i);
    % special case: FragTs(1) = 0 -- just remove the first data point t=0
    if i == 1 && newStartBlockIndex == 0
        newStartBlockIndex = 1;
        startBlockIndex(i) = 2;
        numValuesInBlock = numValuesInBlock - 1;
    end
    adAdj(newStartBlockIndex:newStartBlockIndex+numValuesInBlock-1) = adInfo.Values(startBlockIndex(i):endBlockIndex(i));
end

