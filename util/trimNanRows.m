function [x,i] = trimNanRows(x)
% delete any rows from a matrix that contain all NaNs
% useful for NaN-padded matrices
% return x, the new matrix with no rows that contain all NaNs
%        i, the row indices of the original matrix that contained all NaNs

i = all(isnan(x),2);
x(i,:) = [];
