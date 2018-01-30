% make a row or column vector a row vector - useful for for loops:
% "for i = rowVector" will iterate through each element of rowVector
% "for i = columnVector" will set i = columnVector for first iteration
function a = makeRowVector(a)

if ~isrow(a)
    if ~iscolumn(a)
        error('Input is neither a row nor a column vector');
    else
        a = a';
    end
end