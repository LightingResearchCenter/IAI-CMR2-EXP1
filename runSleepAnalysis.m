function varargout = runSleepAnalysis
%RUNSLEEPANALYSIS Runs standard sleep analysis

timestamp = datestr(now,'yyyy-mm-dd HHMM');

resetMatlab

%% Dependencies
addpath('C:\Users\jonesg5\Documents\GitHub\circadian')
addpath('C:\Users\jonesg5\Documents\GitHub\d12pack')


%% File paths
programDir = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data';
groupDir   = fullfile(programDir, {'Group_1';'Group_2';'Group_3';'Group_4'}); % Subject group
tablesDir  = fullfile(programDir,   'Sleep_Analysis');   % Save location for tables

xlsxName = [timestamp, ' sleep analysis.xlsx'];
xlsxPath = fullfile(tablesDir, xlsxName);
matName = [timestamp, ' sleep analysis.mat'];
matPath = fullfile(tablesDir, matName);

intDt = [2016, 12, 30, 17,  0,  0;...
         2017,  5, 23, 17,  0,  0;...
         2017,  7, 26, 17,  0,  0;...
         2017,  9, 28, 17,  0,  0];
interventionDates = datetime(intDt,'TimeZone','America/New_York');

%% Iterate through subjects
iCollector = 1;
for iGroup = 1:numel(groupDir)
    [recentDirs, subList] = getRecentSubDirs(groupDir{iGroup});
    
    activityFiles	= fullfile(recentDirs,'activityReading.csv');
    sleepFiles      = fullfile(recentDirs,'sleepState.csv');
    
    thisInterventionDate = interventionDates(iGroup);
    
    nSub = numel(subList);
    for iSub = 1:nSub
        %Identify subject
        thisSub = subList{iSub};
        
        % Read data from files
        activityReading = readtable(activityFiles{iSub});
        sleepState      = readtable(sleepFiles{iSub});
        
        % Convert data formats
        time = datenum(datetime(activityReading.timeUTC,'ConvertFrom','posixtime','TimeZone','America/New_York'));
        activity = activityReading.activityIndex;
        epoch = samplingrate(mode(diff(time)),'days');
        bedLog = sleepState2BedLog(sleepState);
        
        % Iterate through bedLog
        for iBed = 1:numel(bedLog)
            bedTime = datenum(bedLog(iBed).BedTime);
            getupTime = datenum(bedLog(iBed).RiseTime);
            analysisStartTime = bedTime - 20/(60*24);
            analysisEndTime = getupTime + 20/(60*24);
            
            param = sleep.sleep(time,activity,epoch,analysisStartTime,analysisEndTime,bedTime,getupTime,'auto');
            param.subject = thisSub;
            if bedLog(iBed).BedTime < thisInterventionDate
                param.protocol = 'baseline';
            else
                param.protocol = 'intervention';
            end
            param.reportedBedTime = bedLog(iBed).BedTime;
            param.reportedRiseTime = bedLog(iBed).RiseTime;
            
            paramCollector{iCollector,1} = param;
            iCollector = iCollector + 1;
        end
    end
end


%% Process results
% Remove empty results
idxEmpty = cellfun(@isempty, paramCollector);
paramCollector(idxEmpty) = [];
% Combine tables
P = vertcat(paramCollector{:});
P = struct2table(P);
% Move last 3 fields to front
P = [P(:,30:33),P(:,1:29)];

%% Save results to disk
writetable(P, xlsxPath);
save(matPath,'P');

%%
if nargout > 0
    varargout{1} = P;
end
end


function resetMatlab
fclose('all');
close all
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


function bedLog = sleepState2BedLog(sleepState)
% Convert time
sleepState.datetime = datetime(sleepState.timeUTC,'ConvertFrom','posixtime','TimeZone','America/New_York');
BedTimes = sleepState.datetime(strcmp('Sleeping',sleepState.sleepState));
RiseTimesTemp = sleepState.datetime(strcmp('Awake',sleepState.sleepState));

% Find matched pairs
RiseTimes = NaT(size(BedTimes),'TimeZone','America/New_York');
for iBed = 1:numel(BedTimes)-1
    idx = RiseTimesTemp > BedTimes(iBed) & RiseTimesTemp < BedTimes(iBed+1);
    if any(idx)
        RiseTimes(iBed) = min(RiseTimesTemp(idx));
    end
end
idx = RiseTimesTemp > BedTimes(end);
RiseTimes(end) = min(RiseTimesTemp(idx));

% Remove BedTimes that were not matched
idxNaT = isnat(RiseTimes);
BedTimes(idxNaT) = [];
RiseTimes(idxNaT) = [];

% Create bedLog object
bedLog = d12pack.BedLogData(BedTimes,RiseTimes);

end


