function cols = adjustColor(cols, multFactor, addFactor)

cols = cols * multFactor + addFactor;

% make colors in bounds of 0 to 1
cols = max(zeros(size(cols)), min(ones(size(cols)), cols));
