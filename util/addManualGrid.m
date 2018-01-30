function addManualGrid(ax, isAddMinor)

if nargin == 1
    isAddMinor = 1;
end

gridMajorAlpha = 0.15;
gridMinorAlpha = 0.25;

hold on;

% Obtain the X tick mark locations
xMajorTick = get(ax, 'XTick'); 
xMajorTickSep = xMajorTick(2) - xMajorTick(1);
gridColMajor = get(ax, 'GridColor');
gridColMajor(4) = gridMajorAlpha; % add secret alpha
% Create line data
XMajor = repmat(xMajorTick, 2, 1);
YMajor = repmat(get(ax, 'YLim')', 1, size(xMajorTick,2));
% Plot grid lines
majorH = plot(XMajor, YMajor, 'Color', gridColMajor, 'LineStyle', '-');
% move the grid lines to the background
uistack(majorH, 'bottom');

% Obtain the Y tick mark locations
yMajorTick = get(ax, 'YTick'); 
yMajorTickSep = yMajorTick(2) - yMajorTick(1);
gridColMajor = get(ax, 'GridColor');
gridColMajor(4) = 0.15; % add secret alpha
% Create line data
XMajor = repmat(get(ax, 'XLim')', 1, size(yMajorTick,2));
YMajor = repmat(yMajorTick, 2, 1);
% Plot grid lines
hold on;
majorH = plot(XMajor, YMajor, 'Color', gridColMajor, 'LineStyle', '-');
% move the grid lines to the background
uistack(majorH, 'bottom');

if ~isAddMinor
    return;
end

% draw minor gridlines
xMinorTick = xMajorTick(1) - xMajorTickSep/2 : xMajorTickSep : xMajorTick(end) + xMajorTickSep/2;
gridColMinor = gridColMajor;
gridColMinor(4) = gridMinorAlpha; % add secret alpha
XMinor = repmat(xMinorTick, 2, 1);
YMinor = repmat(get(ax, 'YLim')', 1, size(xMinorTick,2));
minorH = plot(XMinor, YMinor, 'Color', gridColMinor, 'LineStyle', ':');
uistack(minorH, 'bottom');

yMinorTick = yMajorTick(1) - yMajorTickSep/2 : yMajorTickSep : yMajorTick(end) + yMajorTickSep/2;
gridColMinor = gridColMajor;
gridColMinor(4) = 0.25; % add secret alpha
XMinor = repmat(get(ax, 'XLim')', 1, size(yMinorTick,2));
YMinor = repmat(yMinorTick, 2, 1);
minorH = plot(XMinor, YMinor, 'Color', gridColMinor, 'LineStyle', ':');
uistack(minorH, 'bottom');
