function fig_h = figure_tr_inch(w,h,x,y)

if nargin < 3
    x = 0; y = 0;
end

% note for reference, matlab default is 96 dpi so 7 inch = 672 pixels
old_units = get(0,'Units');
set(0,'Units','inches');
scrsz = get(0,'ScreenSize');
set(0,'Units',old_units);

fig_h = figure('Units','inches','Position',[0.05+x max(0,scrsz(4)-0.9-h-y) w h],'Color','w'); % [l b w h]
% subaxis(1,1,1,'MR',0.05,'ML',0.1,'MB',0.1,'MT',0.1); 
subaxis(1, 1, 1, 'MR', 0.2/w, 'ML', 0.8/w, 'MB', 0.6/h, 'MT', 0.5/h);