function struct2var(s)
% take a structure and convert its fields into workspace variables
% source: http://stackoverflow.com/a/3470731
cellfun(@(n,v) assignin('base',n,v),fieldnames(s),struct2cell(s));
