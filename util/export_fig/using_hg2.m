%USING_HG2 Determine if the HG2 graphics pipeline is used
%
%   tf = using_hg2(fig)
%
%IN:
%   fig - handle to the figure in question.
%
%OUT:
%   tf - boolean indicating whether the HG2 graphics pipeline is being used
%        (true) or not (false).

function tf = using_hg2(fig)
try
    % http://www.mathworks.com/matlabcentral/answers/136834-determine-if-using-hg2
    %tf = ~graphicsversion(fig, 'handlegraphics');
    tf = isa(fig, 'matlab.ui.Figure');
catch
    tf = false;
end
end
