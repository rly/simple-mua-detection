function s = var2struct(varargin)
% dump a collection of variables "in" a structure, using the variable names
% as the structure fields
% source: http://stackoverflow.com/a/3470731
names = arrayfun(@inputname,1:nargin,'UniformOutput',false);
s = cell2struct(varargin,names,2);