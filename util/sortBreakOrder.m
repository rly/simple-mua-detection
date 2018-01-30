function [sx,sortInd] = sortBreakOrder(x)
% inefficient sorting algorithm that does not preserve order among equal
% elements

assert(isrow(x) | iscolumn(x));

sortInd = nan(size(x));

ux = unique(sort(x));
count = 1;
for i = 1:numel(ux)
    matches = find(x == ux(i));
    perm = randperm(numel(matches));
    newInd = count:count + numel(matches) - 1;
    sortInd(newInd) = matches(perm);
    count = count + numel(matches);
end

sx = x(sortInd);
