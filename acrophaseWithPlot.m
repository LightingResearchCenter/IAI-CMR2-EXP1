function cosinorCollector = acrophaseWithPlot
%RUNMODEL Runs the pacemaker model on data collected from CMR2 App

fclose('all');
close all
clear
clc

%% Dependencies
addpath('C:\Users\jonesg5\Documents\GitHub\HealthyHomeBlackBox')
addpath('C:\Users\jonesg5\Documents\GitHub\HealthyHomeBlackBox\defines')

%% File paths
topDir = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data';
groupDirs = fullfile(topDir,{'Modified Data'});
plotsDir = fullfile(topDir,'cosinor_plots');

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

activityFiles	= fullfile(recentDirs,'activityReading.csv');
sleepFiles      = fullfile(recentDirs,'sleepState.csv');
pacemakerFiles  = fullfile(recentDirs,'pacemaker.csv');

%%
h = figure;
h.Units = 'inches';
h.Position = [0 0 11 8.5];
h.PaperOrientation = 'landscape';
h.PaperSize = [11 8.5];
h.PaperPosition = [0 0 11 8.5];
h.Renderer = 'painters';


%% Iterate through subjects
nSub = numel(subList);
cosinorCollector = table;

for iSub = nSub:-1:1
    thisSub = subList(iSub);
    
    % Read data from files
    activityReading = readtable(activityFiles{iSub});
    sleep           = readtable(sleepFiles{iSub});
    pacemaker       = readtable(pacemakerFiles{iSub});
    
    % Fill in gaps
    activityReading = LRCgapFillActivityReading(activityReading);
    
    activityReading = sleepState2idx(sleep,activityReading);
    
    appT = pacemaker.tn;
    appX = pacemaker.xn; 
    appXC = pacemaker.xcn; 
    [appDT, ~] = state2dlmo(appT, appX, appXC);
    
    
    % Extract Baseline and Intervention values
    % Baseline
    ax = subplot(2,1,1);
    [acrophaseTime, acroDLMO, mesor, amplitude] = tenDayAcrophase(activityReading, appDT(1), ax);
    title(ax, [subList(iSub), ' Baseline'])
    
    cosinorCollector.subject_id(iSub,1) = thisSub;
    cosinorCollector.session(iSub,1) = {'Baseline'};
    cosinorCollector.acrophase(iSub,1) = acrophaseTime;
    cosinorCollector.mesor(iSub,1) = mesor;
    cosinorCollector.amplitude(iSub,1) = amplitude;
    
    % Intervention
    ax = subplot(2,1,2);
    [acrophaseTime, acroDLMO, mesor, amplitude] = tenDayAcrophase(activityReading, appDT(end), ax);
    title(ax, [subList(iSub), ' Intervention'])
    
    cosinorCollector.subject_id(iSub+nSub,1) = thisSub;
    cosinorCollector.session(iSub+nSub,1) = {'Intervention'};
    cosinorCollector.acrophase(iSub+nSub,1) = acrophaseTime;
    cosinorCollector.mesor(iSub+nSub,1) = mesor;
    cosinorCollector.amplitude(iSub+nSub,1) = amplitude;
    
    saveas(h, fullfile(plotsDir,[subList{iSub},'.pdf']))
    
    clf
end


close all

winopen(plotsDir)


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







