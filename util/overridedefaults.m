%parseargs   [opts] = overridedefaults(varnames, arguments, ignore_unknowns)
%
% Variable argument parsing
%
% function is meant to be used in the context of other functions
% which have variable arguments. Typically, the function using
% variable argument parsing would be written with the following
% header:
%
%    function myfunction(args, ..., varargin)
%
% and would set up some default values for variables: 
%    bin_size = 0.1;
%    thresh   =   2;
%
%       overridedefaults(whos, varargin);
%
%
% varargin can be of two forms:
% 1) A cell array where odd entries are variable names and even entries are
%    the corresponding values
% 2) A struct where the fieldnames are the variable names and the values of
%    the fields are the values (for pairs)
%
%
% OVERRIDEDEFAULTS DOES NOT RETURN ANY VALUES; INSTEAD, IT USES ASSIGNIN
% COMMANDS TO CHANGE OR SET VALUES OF VARIABLES IN THE CALLING
% FUNCTION'S SPACE.
%
%
%
% PARAMETERS:
% -----------
% -varnames      The list of variable names which are defined in the
%                   calling function
% -arguments     The varargin list, I.e. a row cell array.
%                value for the variable.
%
%
% Example:
% --------
% Let's say i have a function foo
% function foo(x,varargin)
%   a = 5;
%   b=  1;
%   overridedefaults(whos, varargin);
%
% Then in the workspace I call:
%   foo(100,'a',1,'b',2)
%
% This will overide the values of a and b to be 1 and 2.
%
% Note that the arguments to parseargs may be in any order-- the
% only ordering restriction is that whatever immediately follows
% pair names (e.g. 'blob') will be interpreted as the value to be
% assigned to them (e.g. 'blob' takes on the value 'fuff!');
%


function [varargout] = overridedefaults(varnames, arguments, ignore_unknowns)

if nargin < 3, ignore_unknowns=true; end;


% Now we assign the value to those passed by arguments.
if numel(arguments)==1 && isstruct(arguments{1})
    arguments=arguments{1};
    fn=fieldnames(arguments);
    for arg=1:numel(fn)
        switch fn{arg}
            case varnames
                assignin('caller',fn{arg}, arguments.(fn{arg}));
                out.(fn{arg})=arguments.(fn{arg});
           
            otherwise
                if ignore_unknowns
                    warning('OD:unknown','Variable %s not defined in caller. Skipping.',fn{arg});
                else
                    assignin('caller',fn{arg}, arguments.(fn{arg}));
                end
        end
    end
    
else
    arg = 1;  while arg <= length(arguments),
        
        switch arguments{arg},
            
            case varnames,
                if arg+1 <= length(arguments)
                    assignin('caller', arguments{arg}, arguments{arg+1});
                    arg = arg+1;
                end;
                
                
            otherwise
                if ignore_unknowns
                    warning('OD:unknown','Variable %s not defined in caller. Skipping.',arguments{arg});
                else
                    assignin('caller',fn{arg}, arguments.(fn{arg}));
                end
                 arg = arg+1;
        end;
        arg = arg+1; end;
end
if nargout>0
    varargout{1}=out;
end
return;
