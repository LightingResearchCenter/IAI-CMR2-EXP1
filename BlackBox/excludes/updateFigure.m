function updateFigure(axisHandles,textHandle,filePaths,OutputStruct,bedTime,riseTime,workStart,workEnd)
%UPDATEFIGURE Summary of this function goes here
%   Detailed explanation goes here

axInput     = axisHandles.axInput;
axPState	= axisHandles.axPState;
axSchedule	= axisHandles.axSchedule;
axActual	= axisHandles.axActual;
axDTGoal	= axisHandles.axDTGoal;

% Read data from disk
filePointers = LRCopen(filePaths,'r');
lightReading	= LRCread_lightReading(filePointers.lightReading);
activityReading	= LRCread_activityReading(filePointers.activityReading);
pacemaker       = LRCread_pacemaker(filePointers.pacemaker);
LRCclose(filePointers);

distanceToGoal = OutputStruct.distanceToGoal;

timeCS = unix2datenum(LRCutc2local(lightReading.timeUTC,lightReading.timeOffset));
CS = lightReading.cs;
timeAI = unix2datenum(LRCutc2local(activityReading.timeUTC,activityReading.timeOffset));
AI = activityReading.activityIndex;

[timeScene,scene] = LRCtreatment2plot(timeCS(end),OutputStruct.treatment,OutputStruct.pacemaker.runTimeOffset(end));

[timeActualScene,actualScene] = LRCscene2actual(timeScene,scene,bedTime,riseTime,workStart,workEnd);

if isempty(pacemaker.tn)
    tn = 0;
    xn = 0;
    xcn = 0;
    xArray = 0;
    xcArray = 0;
%     xAcrophase = 0;
%     xcAcrophase = 0;
elseif isnan(pacemaker.tn(end))
    tn = 0;
    xn = 0;
    xcn = 0;
    xArray = 0;
    xcArray = 0;
%     xAcrophase = 0;
%     xcAcrophase = 0;
else
    tn = pacemaker.tn(end);
    xn = pacemaker.xn(end);
    xcn = pacemaker.xcn(end);
    xArray = pacemaker.xn;
    xcArray = pacemaker.xcn;
%     [~,xAcrophase,xcAcrophase] = refPhaseTime2StateAtTime(activityAcrophase,mod(tn,86400)+activityReading.timeOffset,'activityAcrophase');
end

xNeedle = [0,-cos(distanceToGoal/86400*pi+pi/2)];
yNeedle = [0,sin(distanceToGoal/86400*pi+pi/2)];


set(axInput,'XLim',[max(timeCS)-10, max(timeCS)],'XTick',floor(max(timeCS)-10):ceil(max(timeCS)));
datetick(axInput,'x','mm/dd','keeplimits','keepticks')

set(axSchedule,'XLim',[timeCS(end),timeCS(end)+2]);
LRCscheduleXlabels(axSchedule)

set(axActual,'XLim',[timeCS(end),timeCS(end)+2]);
LRCscheduleXlabels(axActual)

set(textHandle,'String',num2str(distanceToGoal/3600,'%.2f'));

refreshdata(gcf,'caller');
drawnow;



end

