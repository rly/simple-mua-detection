function plotRecordingGrid(centerCoords, ratio, scale, tubesToColor, color)

hold on;
for i = 1:size(centerCoords, 1)
    % center coords (i,[2 1]): rotate -90 deg and flip across y axis
    h = rectangle('Position', [centerCoords(i,[2 1])-1/ratio 2/ratio 2/ratio]*scale, 'Curvature', [1 1]);
    if sum(i == tubesToColor) > 0
        set(h, 'FaceColor', color);
    end
    text(centerCoords(i,2)*scale, centerCoords(i,1)*scale, num2str(i), 'HorizontalAlignment', 'center');
end

rectangle('Position', [-1 -1 2 2]*scale, 'Curvature', [1 1], 'LineWidth', 2);
axis equal;

% for i = 1:N
%     circleCoords = circle(centerCoords(i,:), 1/ratio, 50);
%     % rotate -90 deg and flip across y axis
%     circleCoords = [circleCoords(:,2) circleCoords(:,1)];
%     h = plot(circleCoords(:,1), circleCoords(:,2), 'k');
% 
%     text(centerCoords(i,2), centerCoords(i,1), num2str(i), 'HorizontalAlignment', 'center');
% end
% circleCoords = circle([0 0], 1, 200);
% plot(circleCoords(:,1), circleCoords(:,2), 'k', 'LineWidth', 2);
% axis equal;