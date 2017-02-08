function [figureHandle,axisHandles,textHandle] = createFigure
%CREATEFIGURE Summary of this function goes here
%   Detailed explanation goes here

figureHandle = figure;
configureFigure(figureHandle);

% Plot of simulated input
axInput = subplot(3,4,[1,4]); % rows, columns, grid position
configureAxInput(axInput);

% Plot of phase state
axPState = subplot(3,4,5); % rows, columns, grid position
configureAxPState(axPState);

% Display of treatment schedule
axSchedule	= subplot(3,4,[6,7]); % rows, columns, grid position
configureAxSchedule(axSchedule);

% Display of actual schedule
axActual	= subplot(3,4,[10,11]);
configureAxActual(axActual);

% Display of distance to goal
axDTGoal = subplot(3,4,8); % rows, columns, grid position
textHandle = configureAxDTGoal(axDTGoal);

% Create axis for buttons
axButtons = subplot(3,4,9); % rows, columns, grid position
set(axButtons,'Tag','ControlsAxis');
set(axButtons,'Visible','off');
axButtonsUnits = get(axButtons,'Units');
set(axButtons,'Units','pixels');
axButtonsPosition = get(axButtons,'Position');
set(axButtons,'Units',axButtonsUnits);
panelHandle = LRCcreate_uipanel(figureHandle,axButtonsPosition);
% Create stop button
createStopButton(panelHandle);

axisHandles = struct(           ...
    'axInput',      axInput,	...
    'axPState',     axPState,	...
    'axSchedule',   axSchedule,	...
    'axActual',     axActual,   ...
    'axDTGoal',     axDTGoal	...
    );

end

function rgb = color1

rgb = [0.0000, 0.4470, 0.7410];

end

function rgb = color2

rgb = [0.8500, 0.3250, 0.0980];

end


function configureFigure(figureHandle)
%CONFIGUREFIGURE Intialize the figure settings

figureUnits = get(figureHandle,'Units');
set(figureHandle,'Units','normalized');
set(figureHandle,'Position',[0 0 1 1]);
set(figureHandle,'Units',figureUnits);
set(figureHandle,'SizeChangedFcn',@LRCresize_uipanel);

end

function configureAxInput(axisHandle)
%CONFIGUREAXIS1 Initialize the first axis

hold(axisHandle,'on');

% Create empty data set
nowDatenum = now;
samplingInterval = 30/86400; % 30 seconds in datenum format
time = nowDatenum:samplingInterval:nowDatenum+10;
CS = zeros(size(time));
AI = zeros(size(time));

set(axisHandle,'YLim',[0,1],'XLim',[time(1),time(end)]);

plotHandle = plot(axisHandle,time,CS,time,AI);

set(plotHandle(1),'Color',color1);
set(plotHandle(2),'Color',color2);

datetick(axisHandle,'x','mm/dd','keeplimits','keepticks')
xlabel('Time')
ylabel('CS and AI')
legend('Circadian Stimulus (CS)','Activity Index (AI)','Location','North','Orientation','Horizontal');
title('Simulated Input');

hold(axisHandle,'off');

% Link data
set(plotHandle(1),'XDataSource','timeCS');
set(plotHandle(1),'YDataSource','CS');
set(plotHandle(2),'XDataSource','timeAI');
set(plotHandle(2),'YDataSource','AI');
end

function configureAxPState(axisHandle)
%CONFIGUREAXIS2 Initialize the second axis

% Create empty data set
xf = 0;
xcf = 0;
xArray = 0;
xcArray = 0;

plotHandle = plot(axisHandle,xArray,xcArray,'-',xf,xcf,'o');

set(plotHandle(1),'Color',color1);
set(plotHandle(2),'Color',color2);

set(axisHandle,'YLim',[-1.2,1.2],'XLim',[-1.2,1.2]);
set(axisHandle,'DataAspectRatio',[1,1,1]);
axis(axisHandle,'manual');

title('Pacemaker Phase State');

% Link data
set(plotHandle(1),'XDataSource','xArray');
set(plotHandle(1),'YDataSource','xcArray');
set(plotHandle(2),'XDataSource','xn');
set(plotHandle(2),'YDataSource','xcn');

end

function configureAxSchedule(axisHandle)
%CONFIGUREAXIS3 Initialize the third axis

hold(axisHandle,'on');

% Create empty data set
nowDatenum = now;

time = 0;
scene = 0;

set(axisHandle,'YLim',[0,1]);
set(axisHandle,'YLimMode','manual');
set(axisHandle,'XLim',[nowDatenum,nowDatenum+2]);
set(axisHandle,'YTick',[0,0.25,1]);
set(axisHandle,'YTickLabel',{'No CS','Low CS','High CS'});

plotHandle = area(axisHandle,time,scene);
set(plotHandle,'FaceColor',color1);
set(plotHandle,'EdgeColor','none');
set(plotHandle,'LineStyle','none');

LRCscheduleXlabels(axisHandle);

xlabel('Time');
ylabel('Scene');
title('Recommended Lighting Schedule');

hold(axisHandle,'off');

% Link data
set(plotHandle(1),'XDataSource','timeScene');
set(plotHandle(1),'YDataSource','scene');
end

function configureAxActual(axisHandle)
%CONFIGUREAXIS3 Initialize the third axis

hold(axisHandle,'on');

% Create empty data set
nowDatenum = now;

time = 0;
scene = 0;

set(axisHandle,'YLim',[0,1]);
set(axisHandle,'YLimMode','manual');
set(axisHandle,'XLim',[nowDatenum,nowDatenum+2]);
set(axisHandle,'YTick',[0,0.25,1]);
set(axisHandle,'YTickLabel',{'Off','Low CS','High CS'});

plotHandle = area(axisHandle,time,scene);
set(plotHandle,'FaceColor',color1);
set(plotHandle,'EdgeColor','none');
set(plotHandle,'LineStyle','none');

LRCscheduleXlabels(axisHandle);

xlabel('Time');
ylabel('Scene');
title('Actual Lighting Schedule');

hold(axisHandle,'off');

% Link data
set(plotHandle(1),'XDataSource','timeActualScene');
set(plotHandle(1),'YDataSource','actualScene');
end

function textHandle = configureAxDTGoal(axisHandle)
%CONFIGUREAXIS4 Initialize the fourth axis

theta = 0:.1:pi;
x1ring = 0.7*cos(theta);
y1ring = 0.7*sin(theta);
plotHandle1 = plot(axisHandle,x1ring,y1ring,'k-');
hold on
plotHandle2 = plot([0,0],[0,1],'r-','LineWidth',2);
hold off
set(gca,'XTick',[],'YTick',[])
textHandle = text(-0.25,-0.5,'NaN','FontSize',14);

set(axisHandle,'YLim',[-1.2,1.2],'XLim',[-1.2,1.2]);
set(axisHandle,'DataAspectRatio',[1,1,1]);
axis(axisHandle,'manual');

title({'Distance to Goal';'Phase Angle (hours)'});

% Link data
set(plotHandle2,'XDataSource','xNeedle');
set(plotHandle2,'YDataSource','yNeedle');
end
