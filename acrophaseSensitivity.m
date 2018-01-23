function acrophaseSensitivity

close all

paths = genPaths;

windowDuration_days = 3:1/24:10;
analysisDelay_days  = 0:1/24:10;

nDur = numel(windowDuration_days);
nDel = numel(analysisDelay_days);

% windowDuration_days = repmat(windowDuration_days,nDel,1);
% analysisDelay_days  = repmat(analysisDelay_days',1,nDur);

[windowDuration_days, analysisDelay_days] = meshgrid(windowDuration_days, analysisDelay_days);

windowDuration_days = windowDuration_days(:);
analysisDelay_days  = analysisDelay_days(:);

idxGreater = (windowDuration_days + analysisDelay_days) > 14;

windowDuration_days(idxGreater) = [];
analysisDelay_days(idxGreater)  = [];

windowDuration_sec = 24*60*60*windowDuration_days;
analysisDelay_sec  = 24*60*60*analysisDelay_days;

for iSub = numel(paths.subject):-1:1

activityReading = readtable(paths.activity{iSub});
pacemaker       = readtable(paths.pacemaker{iSub});

activityReading = utc2local_posix(activityReading);
pacemaker       = utc2local_posix(pacemaker);

[activityReading, t0] = trim2baseline(activityReading, pacemaker);

func = @(dur, del) acrophase(dur, del, activityReading, t0);

phi_hours(:,:,iSub) = arrayfun(func, windowDuration_sec, analysisDelay_sec);
phiDeviation_hours(:,:,iSub) = phi_hours(:,:,iSub) - median(phi_hours(:,:,iSub));

end

x = windowDuration_days;
y = analysisDelay_days;
z = mean(phiDeviation_hours,3);
tri = delaunay(x,y);

figure
h = trisurf(tri, x, y, z);
ax = gca;
axis('vis3d')
l = light('Position',[-50 -15 29]);

lighting phong
shading interp

xlabel('Window Duration (days)')
ylabel('Analysis Delay (days)')
zlabel('Acrophase Deviation from Median (hours)')
title({'Activity Acrophase Sensitivity';'IAI CMR2 Subjects'})

p = patch([ax.XLim(1) ax.XLim(2) ax.XLim(2) ax.XLim(1)],[ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2)],[0 0 0 0],[0 0 0 0]);
p.FaceColor = 'red';
p.FaceAlpha = 0.5;
p.EdgeColor = 'none';



dlmo = [21.80, 21.35, 20.78, 21.55, 21.10, 20.05, 21.53, 20.75, 20.75, 23.40, 23.00]'
;

for iFit = size(phiDeviation_hours,1)
    thisY = phi_hours(iFit,:,:);
    thisY = thisY(:);
    [p,S] = polyfit(dlmo, thisY, 1);
    
end


end


function tbl = utc2local_posix(tbl)

if ismember('timeUTC', tbl.Properties.VariableNames)
    t = datetime(tbl.timeUTC,'ConvertFrom','posixtime','TimeZone','UTC');
else
    t = datetime(tbl.tn,'ConvertFrom','posixtime','TimeZone','UTC');
end
t.TimeZone = 'local';
tbl.timeLocal = t;
t.TimeZone = '';
tbl.timeLocal_sec = posixtime(t);

end

function [activityReading, t0] = trim2baseline(activityReading, pacemaker)

ti = dateshift(activityReading.timeLocal(1),'end','day');
tf = dateshift(pacemaker.timeLocal(1),'start','day');

idx = activityReading.timeLocal >= ti & activityReading.timeLocal <= tf;

activityReading = activityReading(idx,:);

ti.TimeZone = '';
t0 = posixtime(ti);

end

function phi_hours = acrophase(dur, del, activityReading, t0)

ti = t0 + del;
tf = ti + dur;

idx = activityReading.timeLocal_sec >= ti & activityReading.timeLocal_sec < tf;

t  = activityReading.timeLocal_sec(idx);
ai = activityReading.activityIndex(idx);

phi_hours = 12*cosinorFit(t, ai)/pi;

end


function phi = cosinorFit(timeArraySec, valueArray)
% LRCCOSINORFIT Simplified cosinor fit
%   time is the timestamps in seconds
%   value is the set of values you're fitting

% preallocate variables
C = zeros(3, 3);
D = zeros(1, 3);

n = numel(timeArraySec);
xj    = zeros(n,1);
zj    = zeros(n,1);

omega = 2*pi/86400;
xj(:,1) = cos(omega*timeArraySec);
zj(:,1) = sin(omega*timeArraySec);

yj = zeros(size(xj));
yj(:,1) = xj(:,1);
yj(:,2) = zj(:,1);

C(1, 1) = n;
C(1, 2) = sum(xj(:,1));
C(2, 1) = sum(xj(:,1));
C(1, 3) = sum(zj(:,1));
C(3, 1) = sum(zj(:,1));

for i1 = 2:3
    for j1 = 2:3
        C(i1, j1) = sum(yj(:,(i1 - 1)).*yj(:,(j1 - 1)));
    end
end

D(1) = sum(valueArray);
for i2 = 2:3
    D(i2) = sum(yj(:,(i2 - 1)).*(valueArray));
end

D = D';

x = C\D;

phi = -atan2(x(3), x(2));

end


function paths = genPaths
%% File paths
topDir = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data';
groupDirs = fullfile(topDir,{'Modified Data'});

for iGroup = 1:numel(groupDirs)
    thisGroup = groupDirs{iGroup};
    listing = dir(fullfile(thisGroup,'subject*'));
    subListTemp = regexprep({listing.name}','subject (\d\d\d).*','$1');
    subDirsTemp = fullfile(thisGroup,{listing.name}');
    recentDirsTemp = cell(size(subListTemp));
    for iSub = 1:numel(subDirsTemp)
        subListing = dir(fullfile(subDirsTemp{iSub},'*_archive'));
        if ~isempty(subListing)
            fileDates = datetime(regexprep({subListing.name}','...._(\d\d\d\d)_(\d\d)_(\d\d)_(\d\d)_(\d\d)_(\d\d)_archive','$1-$2-$3 $4:$5:$6'));
            [~,maxIdx] = max(fileDates);
            recentDirsTemp{iSub} = fullfile(subDirsTemp{iSub},subListing(maxIdx).name);
        end
    end
    % remove empty subjects
    idxEmpty = cellfun(@isempty,recentDirsTemp);
    subListTemp(idxEmpty) = [];
    recentDirsTemp(idxEmpty) = [];
    
    if iGroup == 1
        subList    = subListTemp;
        subDirs    = subDirsTemp;
        recentDirs = recentDirsTemp;
    else
        subList    = vertcat(subList, subListTemp);
        subDirs    = vertcat(subDirs, subDirsTemp);
        recentDirs = vertcat(recentDirs, recentDirsTemp);
    end
end

paths = table;
paths.subject   = subList;
paths.light     = fullfile(recentDirs,'lightReading.csv');
paths.activity	= fullfile(recentDirs,'activityReading.csv');
paths.glasses	= fullfile(recentDirs,'glassesState.csv');
paths.sleep     = fullfile(recentDirs,'sleepState.csv');
paths.pacemaker = fullfile(recentDirs,'pacemaker.csv');

end