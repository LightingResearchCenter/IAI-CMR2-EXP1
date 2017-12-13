function msfscCollector = roennebergMidSleep
%ROENNEBERGMIDSLEEP Summary of this function goes here
%   Detailed explanation goes here

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

lightFiles      = fullfile(recentDirs,'lightReading.csv');
activityFiles	= fullfile(recentDirs,'activityReading.csv');
glassesFiles	= fullfile(recentDirs,'glassesState.csv');
sleepFiles      = fullfile(recentDirs,'sleepState.csv');
pacemakerFiles  = fullfile(recentDirs,'pacemaker.csv');

%% Iterate through subjects
nSub = numel(subList);
msfscCollector = table;
msfscCollector.subject_id = subList;

intDt = [2016, 12, 30, 17,  0,  0;...
         2017,  5, 23, 17,  0,  0;...
         2017,  7, 26, 17,  0,  0;...
         2017,  9, 28, 17,  0,  0];
interventionDates = datetime(intDt,'TimeZone','America/New_York');

for iSub = 1:nSub
    % Read data from files
    sleep           = ReadLog(sleepFiles{iSub});
    [SPrep, GU] = sleepState2Log(sleep);
    
    switch subList{iSub}
        case {'300', '301', '302', '303'}
            intervention = interventionDates(1);
        case {'304', '305', '306', '307'}
            intervention = interventionDates(2);
        case {'308', '309', '310'}
            intervention = interventionDates(3);
        case {'312', '313', '314', '315', '316'}
            intervention = interventionDates(4);
    end
    idxBaseline = GU < intervention;
    idxIntervention = ~idxBaseline;
    
    msfscCollector.MSFsc_baseline(iSub) = chronotype(SPrep(idxBaseline),GU(idxBaseline));
    msfscCollector.Burgess_DLMO_baseline(iSub) = mod(1.2*msfscCollector.MSFsc_baseline(iSub) + duration(17.18,0,0), duration(24,0,0));
    msfscCollector.Carskadon_DLMO_baseline(iSub) = mod(0.7*msfscCollector.MSFsc_baseline(iSub) + duration(18.77,0,0), duration(24,0,0));
    msfscCollector.MSFsc_intervention(iSub) = chronotype(SPrep(idxIntervention),GU(idxIntervention));
    msfscCollector.Burgess_DLMO_intervention(iSub) = mod(1.2*msfscCollector.MSFsc_intervention(iSub) + duration(17.18,0,0), duration(24,0,0));
    msfscCollector.Carskadon_DLMO_intervention(iSub) = mod(0.7*msfscCollector.MSFsc_intervention(iSub) + duration(18.77,0,0), duration(24,0,0));
end

end

function [SPrep, GU] = sleepState2Log(sleep)

nState = numel(sleep.sleepState);
iLog = 1;
for iState = 1:nState
    switch sleep.sleepState{iState}
        case 'Sleeping'
            if (iState ~= nState) && (iState == 1 || strcmp(sleep.sleepState{iState-1},'Awake'))
                SPrep(iLog,1) = sleep.timeLocal(iState);
            else
                continue
            end
        case 'Awake'
            if iState ~= 1 && strcmp(sleep.sleepState{iState-1},'Sleeping')
                GU(iLog,1) = sleep.timeLocal(iState);
                iLog = iLog + 1;
            else
                continue
            end
        otherwise
            error('Sleep state not recognized.')
    end
end

end



function MSFsc = chronotype(SPrep,GU)
% CHRONOTYPE Calculates the sleep debt corrected free day mid-sleep time
%   SPrep = local time of preparing to sleep
%   GU = local time of getting out of bed
%   MSFsc = mid-sleep on free days corrected for accumulated sleep dept


%% Initialize variables
TD = length(SPrep); % total number of days to be analyzed

%% Calculate basic Roennenberg variables for each day
for i1 = TD:-1:1
    [SD(i1),MS(i1),idxW(i1)] = roenneberg(SPrep(i1),GU(i1));
end

%% Calculate workday variables
WD = sum(idxW); % number of workdays
SDw = mean(SD(idxW)); % sleep duration on workdays

%% Calculate free day variables
FD = sum(~idxW); % number of free days
SDf = mean(SD(~idxW)); % sleep duration on free days
SDweek = (SDw*WD + SDf*FD)/TD; % average sleep duration for the week
MSF = mean(MS(~idxW)); % mid-sleep on free days
MSFsc = MSF - (SDf - SDweek)/2; % corrected mid-sleep on free days

%% Correct for roll-over
MSFsc = mod(MSFsc,duration(24,0,0)); % corrected mid-sleep on free days

end

function [SD,MS,W] = roenneberg(SPrep,GU)
%ROENNENBERG Calculates sleep parameters using Roenneberg method
%   Combines Actiware sleep algorithim with Roennenberg sleep parameters
%   SPrep = local time of preparing to sleep
%   GU = local time of getting out of bed


%% Determine if the analysis ends on a workday
dayNumber = weekday(GU);
if dayNumber == 1 || dayNumber == 7
    W = false;
else
    W = true;
end

%% Find sleep onset (SO) and sleep end (SE)
% Find sleep onset (SO)
SO = SPrep;

% Find sleep end (SE)
SE = GU;

%% Calculate sleep duration (SD)
SD = SE - SO;

%% Calculate basic mid-sleep (MS)
MS = timeofday(SO + SD/2);
% if mid-sleep occurs between midnight and noon add 24 hours
if MS < duration(12,0,0)
    MS = MS + duration(24,0,0);
end

end