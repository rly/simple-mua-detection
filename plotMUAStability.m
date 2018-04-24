function plotMUAStability(channelName, ts, t, wf, meanExtractedWaveform, ...
        seExtractedWaveform, thresholds, nWfByWindow, windowLength, isPutativeAxon, ...
        plotFileName)

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

[~,pcaScore,~,~,pcaPctExplained] = pca(wf);

wfNotAxon = wf(~isPutativeAxon,:);
nWfNotAxon = size(wfNotAxon, 1);
meanWfNotAxon = mean(wfNotAxon, 1);
seWfNotAxon = std(wfNotAxon, 0, 1);

wfAxon = wf(isPutativeAxon,:);
nWfAxon = size(wfAxon, 1);
meanWfAxon = mean(wfAxon, 1);
seWfAxon = std(wfAxon, 0, 1);

plotWaveformIndsNotAxon = randperm(nWfNotAxon, min(nWfNotAxon, maxWaveformsPlot));

[~,pcaScoreNotAxon,~,~,pcaPctExplainedNotAxon] = pca(wfNotAxon);

cols = lines(6);
colNotAxon = cols(4,:);
colAxon = cols(2,:);

%% create figure
f = figure_tr_inch(18, 9); clf;
set(gcf, 'Color', 'white');
set(gcf, 'renderer', 'painters');

%% make main title
axBig = axes('Position', [0.04 0.045 0.92 0.91], 'Visible', 'off');
set(get(axBig, 'Title'), 'Visible', 'on')

modTitle = sprintf('Extract MUA - Threshold by Block: %s', channelName);
titleParams = {'Interpreter', 'None', 'FontWeight', 'bold'};
title(modTitle, 'FontSize', 14, titleParams{:});

%% location params
col1PlotW = 0.195;
col2PlotW = 0.195;
col3PlotW = 0.195;
col4PlotW = 0.195;

col1PlotH = 0.15;
col2PlotH = 0.855;
col3PlotH = 0.385;
col4Plot1H = 0.385;
col4Plot2H = 0.15;
col4Plot3H = 0.15;

col1Left = 0.05;
col2Left = col1Left + col1PlotW + 0.05;
col3Left = col2Left + col2PlotW + 0.05;
col4Left = col3Left + col3PlotW + 0.05;

btm = 0.07;
col1Plot4Btm = btm;
col1Plot3Btm = col1Plot4Btm + col1PlotH + 0.085;
col1Plot2Btm = col1Plot3Btm + col1PlotH + 0.085;
col1Plot1Btm = col1Plot2Btm + col1PlotH + 0.085;
col2Plot1Btm = btm;
col3Plot2Btm = btm;
col3Plot1Btm = col3Plot2Btm + col3PlotH + 0.085;
col4Plot1Btm = col3Plot1Btm;
col4Plot2Btm = col1Plot3Btm;
col4Plot3Btm = col1Plot4Btm;

%% plot sample waveforms
axes('Position', [col1Left col1Plot1Btm col1PlotW col1PlotH]); 
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
axes('Position', [col1Left col1Plot2Btm col1PlotW col1PlotH]); 
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
axes('Position', [col1Left col1Plot3Btm col1PlotW col1PlotH]); 
plot(thresholds, '.-', 'MarkerSize', 20);
xlim([0 nWindow+1]);
ylim([-0.05 -0.025]);

title('Spike Thresholds by Window');
xlabel('Window Index');
ylabel('Voltage (mV)');
box off;

%% plot num threshold crossings by window
axes('Position', [col1Left col1Plot4Btm col1PlotW col1PlotH]); 
plot(nWfByWindow, '.-', 'MarkerSize', 20);
xlim([0 nWindow+1]);

title('Threshold Crossings by Window');
xlabel('Window Index');
ylabel('Number of Crossings');
box off;

%% ridge line plot of mean waveforms by window
axes('Position', [col2Left col2Plot1Btm col2PlotW col2PlotH]); 
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

%% plot PC1 vs PC2
axes('Position', [col3Left col3Plot1Btm col3PlotW col3PlotH]); 
hold on;
plot(pcaScore(:,1), pcaScore(:,2), '.', 'Color', colNotAxon);
plot(pcaScore(isPutativeAxon,1), pcaScore(isPutativeAxon,2), '.', 'Color', colAxon);
text(1, 1, sprintf('PC1: %d%% explained', round(pcaPctExplained(1))), ...
        'Units', 'normalized', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
text(1, 0.95, sprintf('PC2: %d%% explained', round(pcaPctExplained(2))), ...
        'Units', 'normalized', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
title('PC1 vs PC2');
xlabel('PC1');
ylabel('PC2');
xlim([min(pcaScore(:,1)) max(pcaScore(:,1))]);
ylim([min(pcaScore(:,2)) max(pcaScore(:,2))]);
box off;

%% plot PC1 vs time
axes('Position', [col3Left col3Plot2Btm col3PlotW col3PlotH]); 
hold on;
plot(pcaScore(:,1), ts, '.', 'Color', colNotAxon);
plot(pcaScore(isPutativeAxon,1), ts(isPutativeAxon), '.', 'Color', colAxon);
title('PC1 vs Time');
xlabel('PC1');
ylabel('Time (s)');
xlim([min(pcaScore(:,1)) max(pcaScore(:,1))]);
ylim([0 ceil(max(ts))]);
box off;

%% plot PC1 vs PC2 without axon
axes('Position', [col4Left col4Plot1Btm col4PlotW col4Plot1H]); 
cols = lines(6);
hold on;
plot(pcaScoreNotAxon(:,1), pcaScoreNotAxon(:,2), '.', 'Color', colNotAxon);
text(1, 1, sprintf('PC1: %d%% explained', round(pcaPctExplainedNotAxon(1))), ...
        'Units', 'normalized', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
text(1, 0.95, sprintf('PC2: %d%% explained', round(pcaPctExplainedNotAxon(2))), ...
        'Units', 'normalized', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
title('PC1 vs PC2 (No Putative Axons)');
xlabel('PC1');
ylabel('PC2');
xlim([min(pcaScoreNotAxon(:,1)) max(pcaScoreNotAxon(:,1))]);
ylim([min(pcaScoreNotAxon(:,2)) max(pcaScoreNotAxon(:,2))]);
box off;

%% plot sample waveforms without axon
axes('Position', [col4Left col4Plot2Btm col4PlotW col4Plot2H]); 
hold on;
plot(t([1 end]), [0 0], 'Color', 0.5*ones(3, 1));
plot(t, wfNotAxon(plotWaveformIndsNotAxon,:)');
xlim(t([1 end]));
ylim([-0.12 0.12]);

title('Sample Waveforms (No Putative Axons)');
xlabel('Time from Trough (ms)');
ylabel('Voltage (mV)');
box off;
set(gca, 'XTick', -0.4:0.2:1);

%% plot mean not axon and mean axon waveforms
axes('Position', [col4Left col4Plot3Btm col4PlotW col4Plot3H]); 
hold on;
plot(t([1 end]), [0 0], 'Color', 0.5*ones(3, 1));
jbfill(t, meanWfNotAxon + seWfNotAxon, ...
        meanWfNotAxon - seWfNotAxon, colNotAxon, colNotAxon, 0.3);
hold on;
jbfill(t, meanWfAxon + seWfAxon, ...
        meanWfAxon - seWfAxon, colAxon, colAxon, 0.3);
hold on;
plot(t, meanWfNotAxon', 'LineWidth', 2, 'Color', colNotAxon);
plot(t, meanWfAxon', 'LineWidth', 2, 'Color', colAxon);
xlim(t([1 end]));

title('Mean Waveforms');
xlabel('Time from Trough (ms)');
ylabel('Voltage (mV)');
box off;
set(gca, 'XTick', -0.4:0.2:1);

text(0.98, 0.18, sprintf('N = %d (%d%%)', nWfNotAxon, round(nWfNotAxon/nWf*100)), 'Color', colNotAxon, 'FontSize', 8, ...
        'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'Units', 'normalized');
text(0.98, 0.1, sprintf('N = %d (%d%%)', nWfAxon, round(nWfAxon/nWf*100)), 'Color', colAxon, 'FontSize', 8, ...
        'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'Units', 'normalized');

text(0.98, 0.02, 'Mean +/- 1 SD', 'FontSize', 8, ...
        'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'Units', 'normalized');

%% save
if ~isempty(plotFileName)
    fprintf('Saving to %s...\n', plotFileName);
    export_fig(plotFileName, '-nocrop');
end
