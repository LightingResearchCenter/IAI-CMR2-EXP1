function PhaseComparison

close all
clear
clc

t = readtable('\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data\Phase Comparison.xlsx','Sheet','for matlab');

f = figure;
f.Units = 'inches';
f.PaperPosition = [0 0 6 6];
f.Position = [0 0 6 6];

vars = {'CS0Oscillator_Model', 'Activity_Acrophase_Plus5', 'Carskadon_Midsleep_Conversion','Free0Day_Corrected_Mid0Sleep'};

nVar = numel(vars);
for iVar = nVar:-1:1
    clf;
    ax = axes;
    xLabel = 'Salivary_DLMO';
    yLabel = vars{iVar};
    plotTitle = vars{iVar};
    xLabel    = regexprep(xLabel, '_', ' ');
    yLabel    = regexprep(yLabel, '_', ' ');
    plotTitle = regexprep(plotTitle, '_', ' ');
    xLabel    = regexprep(xLabel, '0', '-');
    yLabel    = regexprep(yLabel, '0', '-');
    plotTitle = regexprep(plotTitle, '0', '-');
    plotTitle2 = {plotTitle; 'vs Salivary DLMO'};
    
    tSlope{iVar,1} = plotComparison(ax, t.Subject, t.Session, t.Salivary_DLMO, t.(vars{iVar}), xLabel, yLabel, plotTitle2);
    saveas(f, ['\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data\',plotTitle,'.png']);
end

close all

tSlope = vertcat(tSlope{:});

% writetable(tSlope, '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data\Phase Comparison.xlsx','Sheet',3);


end


function tSlope = plotComparison(ax, sub, ses, x, y, xLabel, yLabel, plotTitle)

idxBas = strcmp('Baseline', ses);
idxInt = strcmp('Intervention', ses);
subject = unique(sub);

hold(ax,'on');
for iSub = numel(subject):-1:1
    thisSub = subject(iSub);
    idxSub = sub == thisSub;
    thisX = x(idxSub);
    thisY = y(idxSub);
    plot(ax, thisX, thisY, '-', 'Color', [0.0 0.0 0.0])
    thisC = [[1; 1]  thisX(:)]\thisY(:); % Calculate Parameter Vector
    slope(iSub,1) = thisC(2);
    intercept(iSub,1) = thisC(1);
end
plot(ax, x(idxBas), y(idxBas), '.', 'Color', [237 125  49]./255, 'MarkerSize', 30, 'DisplayName', 'Baseline')
plot(ax, x(idxInt), y(idxInt), '.', 'Color', [ 91 155 213]./255, 'MarkerSize', 30, 'DisplayName', 'Intervention')
hold(ax,'off');
xlabel(ax, [xLabel, ' (hours)'], 'FontSize', 14)
ylabel(ax, [yLabel, ' (hours)'], 'FontSize', 14)

title(ax, plotTitle, 'FontSize', 16, 'FontWeight', 'normal')
ax.FontSize = 14;
ax.XLim = [18 24];
ax.YLim = [18 27];
if strcmp(yLabel, 'Free-Day Corrected Mid-Sleep')
    ax.YLim = [1 8];
end
ax.TickDir = 'out';
ax.DataAspectRatio = [1 1 1];
ax.XTick = ax.XLim(1):ax.XLim(2);

outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

l = legend([ax.Children(2), ax.Children(1)], 'Location', 'SouthOutside', 'Orientation', 'horizontal');
l.Box = 'off';
l.FontSize = 14;

metric = repmat({yLabel},size(slope));

tSlope = table(subject, metric, slope, intercept);


end