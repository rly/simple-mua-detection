function [x,i] = trimAnyNanRows(x)
% delete any rows from a matrix that contain any NaNs
% return x, the new matrix with no rows that contain any NaNs
%        i, the row indices of the original matrix that contained any NaNs

i = any(isnan(x),2);
x(i,:) = [];
