function plotMUAStability(channelName, t, wf, meanExtractedWaveform, ...
        seExtractedWaveform, thresholds, nWfByWindow, windowLength, plotFileName)

%% plot only subset of waveforms if too many
nWf = size(wf, 1);
maxWaveformsPlot = 1000;
plotWaveformInds = randperm(nWf, min(nWf, maxWaveformsPlot));
if nWf > maxWaveformsPlot
    fprintf('Plotting %d out of %d waveforms.\n', maxWaveformsPlot, nWf);
else
    fprintf('Plotting all %d waveforms.\n', nWf);
end

nWindow = numel(nWfByWindow);

%% create figure
f = figure_tr_inch(13, 13); clf;
set(gcf, 'Color', 'white');
set(gcf, 'renderer', 'painters');

%% make main title
axBig = axes('Position', [0.04 0.045 0.92 0.91], 'Visible', 'off');
set(get(axBig, 'Title'), 'Visible', 'on')

modTitle = sprintf('Extract MUA - Threshold by Block: %s', channelName);
titleParams = {'Interpreter', 'None', 'FontWeight', 'bold'};
title(modTitle, 'FontSize', 14, titleParams{:});

%% location params
leftColW = 0.25;
rightColW = 0.58;
leftColPlotH = 0.15;
rightColH = 0.855;

leftColLeft = 0.07;
rightColLeft = leftColLeft + leftColW + 0.06;

btm = 0.07;
leftColPlot3Btm = btm + leftColPlotH + 0.085;
leftColPlot2Btm = leftColPlot3Btm + leftColPlotH + 0.085;
leftColPlot1Btm = leftColPlot2Btm + leftColPlotH + 0.085;

%% plot sample waveforms
axes('Position', [leftColLeft leftColPlot1Btm leftColW leftColPlotH]); 
hold on;
plot(t([1 end]), [0 0], 'Color', 0.5*ones(3, 1));
plot(t, wf(plotWaveformInds,:)');
xlim(t([1 end]));
ylim([-0.12 0.12]);

title('Sample Waveforms');
xlabel('Time from Trough (ms)');
ylabel('Voltage (mV)');
box off;
set(gca, 'XTick', -0.4:0.2:1);

%% plot mean waveforms by window
axes('Position', [leftColLeft leftColPlot2Btm leftColW leftColPlotH]); 
hold on;
plot(t([1 end]), [0 0], 'Color', 0.5*ones(3, 1));
plot(t, meanExtractedWaveform', 'LineWidth', 2);
xlim(t([1 end]));

title('Mean Waveforms by Window');
xlabel('Time from Trough (ms)');
ylabel('Voltage (mV)');
box off;
set(gca, 'XTick', -0.4:0.2:1);

%% plot spike thresholds by window
axes('Position', [leftColLeft leftColPlot3Btm leftColW leftColPlotH]); 
plot(thresholds, '.-', 'MarkerSize', 20);
xlim([0 nWindow+1]);
ylim([-0.05 -0.025]);

title('Spike Thresholds by Window');
xlabel('Window Index');
ylabel('Voltage (mV)');
box off;

%% plot num threshold crossings by window
axes('Position', [leftColLeft btm leftColW leftColPlotH]); 
plot(nWfByWindow, '.-', 'MarkerSize', 20);
xlim([0 nWindow+1]);

title('Threshold Crossings by Window');
xlabel('Window Index');
ylabel('Number of Crossings');
box off;

%% ridge line plot of mean waveforms by window
axes('Position', [rightColLeft btm rightColW rightColH]); 
hold on;
yScale = 50;
col = [0 0 0];
for k = 1:nWindow
    if ~all(isnan(meanExtractedWaveform(k,:)))
        yVal = meanExtractedWaveform(k,:) * yScale + k;
        jbfill(t, yVal + seExtractedWaveform(k,:) * yScale, ...
                yVal - seExtractedWaveform(k,:) * yScale, col, col, 0.3);
        hold on;
        plot(t, yVal, '-', 'Color', col, 'LineWidth', 2);
    else
        plot(t, zeros(size(t)) + k, '--', 'Color', col);
    end
end
xlim([t(1) t(end)]);
ylim([-2 nWindow + 3]);
xlabel('Time from Trough (ms)');
ylabel('Window');
title(sprintf('Waveform by Window (%d ms)', windowLength), 'Interpreter', 'none');
grid on;
box off;
set(gca, 'XTick', -0.4:0.2:1);
text(0.98, 0.02, 'Mean +/- 1 SEM', 'FontSize', 8, 'HorizontalAlignment', 'right', 'Units', 'normalized');

%% save
if ~isempty(plotFileName)
    export_fig(plotFileName, '-nocrop');
end
