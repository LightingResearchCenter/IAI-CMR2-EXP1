function h = runModelGroup4
%RUNMODEL Runs the pacemaker model on data collected from CMR2 App

resetMatlab

%% Dependencies
addpath('C:\Users\jonesg5\Documents\GitHub\HealthyHomeBlackBox')
addpath('C:\Users\jonesg5\Documents\GitHub\HealthyHomeBlackBox\defines')


%% File paths
programDir = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data';
groupDir   = fullfile(programDir, 'Group_4'); % Subject group
plotsDir   = fullfile(groupDir,   'plots');   % Save location for plots

[recentDirs, subList] = getRecentSubDirs(groupDir);

lightFiles      = fullfile(recentDirs,'lightReading.csv');
activityFiles	= fullfile(recentDirs,'activityReading.csv');
glassesFiles	= fullfile(recentDirs,'glassesState.csv');
sleepFiles      = fullfile(recentDirs,'sleepState.csv');
pacemakerFiles  = fullfile(recentDirs,'pacemaker.csv');

%%
h = figure;
h.Units = 'normalized';
h.Position = [0 0 1 1];


%% Iterate through subjects
nSub = numel(subList);
for iSub = 1:nSub
    % Read data from files
    lightReading    = readtable(lightFiles{iSub});
    activityReading = readtable(activityFiles{iSub});
    glasses         = readtable(glassesFiles{iSub});
    pacemaker       = readtable(pacemakerFiles{iSub});
    
%     lightReading = adjustCS(glasses,lightReading);
    
    % % Truncate data to not more than 10 days (defined by LRCreadingDuration)
    % lightReading    = LRCtruncate_lightReading(lightReading,LRCreadingDuration);
    
    %% Fill in any gaps in CS
    lightReading = gapFill(lightReading,LRClightSampleInc);
    
    %% Calculate data bounds and preallocate variables
    time0 = max([lightReading.timeUTC(1), activityReading.timeUTC(1)]);
    timeF = lightReading.timeUTC(end);
    acrophaseWindow = 3*24*60*60; % Window size for acrophase, 3 days in seconds
    modelStep = 0.5*60*60; % Step size to advance model by, 1/2 hours in seconds
    nStep = ceil((timeF - time0)/modelStep)+1;
    matT  = nan(nStep,1);
    matX  = nan(nStep,1);
    matXC = nan(nStep,1);
    CBTmin = nan(nStep,1);
    
    %% Calculate activity acrophase
    AR4acrophase = activityReading(activityReading.timeUTC >= time0 & time0 <= time0 + acrophaseWindow,:);
    [matT(1),matX(1),matXC(1)] = initialAcrophase(AR4acrophase);
    CBTmin(1) = stateAtTime2RefPhaseTime(LRCutc2local(matT(1),activityReading.timeOffset(1)),matX(1),matXC(1))/3600; % Hour of day in local time
    
    for iStep = 2:nStep
        t0  = matT(iStep-1);
        x0  = matX(iStep-1);
        xc0 = matXC(iStep-1);
        tF = time0 + modelStep*(iStep-1);
        t0Local = LRCutc2local(t0,activityReading.timeOffset(1));
        t0LocalRel = LRCabs2relTime(t0Local);
        idx = lightReading.timeUTC > t0 & lightReading.timeUTC <= tF; % light readings in bounds
        CS = lightReading.cs(idx);
        
        if ~any(idx)
            continue
        end
        
        % Advance pacemaker model solution to end of light data
        [tnLocalRel,xn,xcn] = pacemakerModelRun(t0LocalRel,x0,xc0,LRClightSampleInc,CS);
        
        % convert to absoulute Unix time (seconds since Jan 1, 1970)
        matT(iStep) = t0 + (tnLocalRel-t0LocalRel);
        matX(iStep)  = xn;
        matXC(iStep) = xcn;
    end
    
    appT = pacemaker.tn; %vertcat(pacemaker.t0(1),pacemaker.tn);
    appX = pacemaker.xn; %vertcat(pacemaker.x0(1),pacemaker.xn);
    appXC = pacemaker.xcn; %vertcat(pacemaker.xc0(1),pacemaker.xcn);
    
    [matDT, matDLMO] = state2dlmo(matT, matX, matXC);
    [appDT, appDLMO] = state2dlmo(appT, appX, appXC);
    
    nCol = 4;
    p = (iSub-1)*nCol+1;
    ax1 = subplot(nSub,nCol,p:p+2);
    filtDLMO = plotDLMO(ax1, matDT, matDLMO, appDT, appDLMO, subList{iSub});
    
    ax2 = subplot(nSub,nCol,p+3);
    plot(ax2,matX,matXC,'.')
    hold on
    % Plot a unit circle
    theta = 0:0.01:2*pi;
    plot(ax2,cos(theta),sin(theta),'-','LineWidth',1.5,'Color','black')
    plot(ax2,appX,appXC,'x','LineWidth',1.5,'Color','red','MarkerSize',10)
    hold off
    
    ax2.YAxisLocation = 'origin';
    ax2.YLim = [-1.5,1.5];
    ax2.YTick = [];
    
    ax2.XAxisLocation = 'origin';
    ax2.XLim = [-1.5,1.5];
    ax2.XTick = [];
    ax2.DataAspectRatio = [1 1 1];
    ylabel('X_{C}','FontSize',8)
    xlabel('X','FontSize',8)
    title(ax2,['Subject: ',subList{iSub}])
    legend(ax2,'MATLAB','Unit Circle','CMR App','Location','northeastoutside')
    
    %{
    ax3 = subplot(nSub,nCol,p+4);
    deviation = hours(matDLMO - filtDLMO);
    tod = timeofday(matDT);
    plot(ax3,tod,deviation,'.')
    xlabel('Time of Day')
    ylabel('Deviation from filter (hours)')
    grid on
    %}
    
end

h = gcf;
h.PaperOrientation = 'landscape';
h.PaperSize = [17 11];
h.PaperPosition = [-1.5000    0.4844   20.0000   10.0313];
h.Renderer = 'painters';

timestamp = datestr(now,'yyyy-mm-dd HHMM');
saveName = [timestamp,' pacemaker plot.pdf'];
saveDir  = fullfile(plotsDir, saveName);
saveas(h, saveDir);

end


function resetMatlab
fclose('all');
close all
clear
clc
end


function [recentDirs, subList] = getRecentSubDirs(groupDir)
groupLs    = dir(fullfile(groupDir, 'subject*'));
subList    = regexprep({groupLs.name}', 'subject (\d\d\d).*', '$1');
subDirs    = fullfile(groupDir, {groupLs.name}');
recentDirs = cell(size(subList));

regPattern = '.{4}_(\d{4}(_\d\d){5})_archive';
datePattern = 'yyyy_MM_dd_HH_mm_ss';

for iSub = 1:numel(subDirs)
    subListing = dir(fullfile(subDirs{iSub},'*_archive'));
    if ~isempty(subListing)
        arcDate = datetime(regexprep({subListing.name}',regPattern,'$1'),'InputFormat',datePattern,'TimeZone','America/New_York');
        [~,maxIdx] = max(arcDate);
        recentDirs{iSub} = fullfile(subDirs{iSub},subListing(maxIdx).name);
    end
end

% remove empty subjects
idxEmpty = cellfun(@isempty,recentDirs);
subList(idxEmpty) = [];
recentDirs(idxEmpty) = [];

end


%%
function filledT = gapFill(T,expectedInc)
%GAPFILL Resample data to evenly spaced increments filling gaps with 0s.
%   expectedInc must be in the same units as timeUTC
%   timeUTC and cs must be vertical vectors with at least 2 entries

timeUTC = T.timeUTC;

% Find the time between samples
sampleDiff = round(diff(timeUTC)/expectedInc); % Multiples of increment

% Find large gaps between samples
gap = sampleDiff > 1; % Effectively true if sampleDiff is 2 or greater

gapStart = timeUTC([gap;false]); % Start time of each gap
gapEnd   = timeUTC([false;gap]); % End time of each gap
nGap     = numel(gapStart); % Number of gaps

% Create evenly spaced time array
newTimeUTC = (timeUTC(1):expectedInc:timeUTC(end))';

% Create a new table
filledT = table;
filledT.timeUTC = newTimeUTC;

% Extract variable names except for 'timeUTC'
varNames = T.Properties.VariableNames;
varNames = varNames(~strcmp('timeUTC',varNames));

% Iterate through table variables
for iVar = 1:numel(varNames)
    if isnumeric(T.(varNames{iVar})) % If variable is numeric
        % Resample the data to evenly spaced increments
        [timeUTC2, ia, ~] = unique(timeUTC); % Keep only unique time stamps
        filledT.(varNames{iVar}) = interp1(timeUTC2,T.(varNames{iVar})(ia),newTimeUTC,'linear');
    end
end

% Extract variable names except for 'timeUTC'
varNames = filledT.Properties.VariableNames;
varNames = varNames(~strcmp('timeUTC',varNames) & ~strcmp('timeOffset',varNames));

% If there were large gaps replace the interpolated values with 0
if nGap > 0
    for iGap = 1:nGap
        thisStart = gapStart(iGap);
        thisEnd = gapEnd(iGap);
        thisIdx = newTimeUTC > thisStart & newTimeUTC < thisEnd;
        for iVar = 1:numel(varNames)
            filledT.(varNames{iVar})(thisIdx) = 0;
        end
    end
end

end



%%
function [t,x,xc] = initialAcrophase(activityReading)
activityTimeLocal = LRCutc2local(activityReading.timeUTC,activityReading.timeOffset);
% Fit activity data with cosine function
[~,~,acrophaseAngle] = LRCcosinorFit(activityTimeLocal,activityReading.activityIndex);
acrophaseTime = LRCacrophaseAngle2Time(acrophaseAngle);
[tLocalRel,x,xc] = refPhaseTime2StateAtTime(acrophaseTime,mod(activityTimeLocal(1),86400),'activityAcrophase');
% convert back to absolute UTC Unix time
tLocal = tLocalRel + 86400*floor(activityTimeLocal(1)/86400);
t = LRClocal2utc(tLocal,activityReading.timeOffset(1));
end


%%
function [dt, dlmo] = state2dlmo(t, x, xc)

% Convert UNIX time to local datetime
dt = datetime(t, 'ConvertFrom', 'posixtime', 'TimeZone', 'America/New_York');

% Convert datetime to local UNIX time
dt2 = dt; % Copy dt
dt2.TimeZone = ''; % Strip time zone
t2 = posixtime(dt2); % Convert from datetime to UNIX time

% Convert state to DLMO
state2cbtmin = @(tLocal,x,xc)altState2Ref(tLocal,x,xc); % Anonymous function
cbtMin = arrayfun(state2cbtmin, t2, x, xc); % Convert state to CBTmin
dlmo   = duration(mod(cbtMin-7, 24), 0, 0); % Convert CBTmin to DLMO

% Fix date rollover
dlmo(dlmo < duration(12,0,0)) = duration(24,0,0) + dlmo(dlmo < duration(12,0,0));

end

function refPhaseTime = altState2Ref(t,x,xc)

% Convert t from seconds to hours
t = t/3600;
% Remove date component of t
t = mod(t, 24);

arcTangent = atan2(xc,-x); % negative cosine because the model evolves clockwise

omega = pi/12; % approximate angular velocity

refPhaseTimeRadians2 = -(arcTangent - t*omega); % relative time in radians, negative because the model evolves clockwise
refPhaseTime = 12/pi*refPhaseTimeRadians2; % relative time in hours

% Adjust if referencing previous day
if (refPhaseTime<0)
    refPhaseTime = 24+refPhaseTime;
end
refPhaseTime = mod(refPhaseTime,24); % convert values > 24 to principle values
end


%%
function filtDLMO = plotDLMO(ax, matDT, matDLMO, appDT, appDLMO, subject)
%PLOTDLMO

% Filter DLMO
[b, a] = butter(2, 0.01, 'low');
filtDLMO = duration(filtfilt(b, a, hours(matDLMO)), 0, 0);

%     yyaxis(ax1, 'left')
%     dt = datetime(unix2datenum(LRCutc2local(lightReading.timeUTC,lightReading.timeOffset)),'ConvertFrom','datenum');
%     a = area(dt,lightReading.adjCS,'EdgeColor','none','FaceColor',[0.6 0.6 0.6]);
%
%     yyaxis(ax1, 'right')

% Plot data
plot(matDT, matDLMO, '.')
hold on
% plot(matDT, filtDLMO, '-','LineWidth',1.5,'Color','black')
plot(appDT, appDLMO,  'x','LineWidth',1.5,'Color','red','MarkerSize',10)
hold off

grid on
yMax = ceil(max(hours(vertcat(matDLMO,appDLMO))));
yMin = yMax - 6;
ax.YLim = duration([yMin, yMax], 0, 0);
ax.YTick = ax.YLim(1):duration(1,0,0):ax.YLim(2);
ytickformat('hh:mm');

ax.XLim = [dateshift(matDT(1),'start','day'),dateshift(matDT(end),'end','day')];
ax.XTick = ax.XLim(1):ax.XLim(2);
xtickformat('MM/dd');
ax.XTickLabelRotation = 35;
ax.FontSize = 8;
title(ax,['Subject: ',subject])
ylabel('Time of Day')
% legend(ax,'Matlab DLMO','Filtered Matlab DLMO','CMR App DLMO','Location','northeastoutside')
legend(ax,'Matlab DLMO','CMR App DLMO','Location','northeastoutside')

% Plot notes
drawnow

if numel(appDT) > 0
    plotAnnotation(appDT(1), appDLMO(1), false)
end

if numel(appDT) > 1
    isOver = abs(appDLMO(end)-appDLMO(1)) > duration(2,0,0);
    appDelta = appDLMO(end)-appDLMO(1);
    
    [lowMatDelta, lowMatIdx] = min(matDLMO - appDLMO(1));
    if lowMatDelta < appDelta
        lowMatDLMO = matDLMO(lowMatIdx);
        lowMatDT = matDT(lowMatIdx);
        
        if abs(lowMatDT-appDT(end)) < duration(48,0,0)
            dy1 = -0.125;
            dy2 =  0.5;
        else
            dy1 = 0;
            dy2 = 0;
        end
        
        plotAnnotation(  lowMatDT,   lowMatDLMO, isOver, lowMatDelta, dy1)
        plotAnnotation(appDT(end), appDLMO(end), isOver, appDelta,    dy2)
    else
        plotAnnotation(appDT(end), appDLMO(end), isOver, appDelta)
    end
end

end


%%
function plotAnnotation(x, y, isOver, varargin)
ax = gca;

y.Format = 'hh:mm';
str = char(y);

if nargin >= 4
    delta = varargin{1};
    delta.Format = 'hh:mm';
    str = sprintf([str,'\n\\Delta = ',char(delta)]);
end

if nargin >= 5
    dy = varargin{2};
else
    dy = 0;
end

if isOver
    X = [x-duration(12,0,0), x];
    Y = [y+duration(1+dy,15,0), y];
else
    X = [x-duration(12,0,0), x];
    Y = [y-duration(1+dy,15,0), y];
end

[Xf,Yf] = ds2nfu(X,Y);

h = annotation('textarrow',Xf,Yf,'String',str);
h.FontSize = 8;

end





