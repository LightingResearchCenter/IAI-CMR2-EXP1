function newActivityReading = LRCgapFillActivityReading(activityReading, startTime)
%LRCGAPFILL Resample data to evenly spaced increments filling gaps with 0s.
%   expectedInc must be in the same units as timeUTC
%   timeUTC and cs must be vertical vectors with at least 2 entries


if ~isdatetime(activityReading.timeUTC(1))
    activityReading.timeUTC = datetime(activityReading.timeUTC,'ConvertFrom','posixtime','TimeZone','UTC');
    startTime = datetime(startTime,'ConvertFrom','posixtime','TimeZone','UTC');
    unixFlag = true;
else
    unixFlag = false;
end

expectedInc = duration(0, 0, 180);

newActivityReading = table;

% Fix time stamps
[~,ia,~] = unique(activityReading.timeUTC,'last');
activityReading = activityReading(ia,:);

% Find the time between samples
sampleDiff = round(diff(activityReading.timeUTC)/expectedInc); % Multiples of increment

% Find large gaps between samples
gap = sampleDiff > 1; % Effectively true if sampleDiff is 2 or greater

gapStart = activityReading.timeUTC([gap;false]); % Start time of each gap
gapEnd = activityReading.timeUTC([false;gap]); % End time of each gap
nGap = numel(gapStart); % Number of gaps

% Create evenly spaced time array
newActivityReading.timeUTC = (startTime:expectedInc:max(activityReading.timeUTC))'; % Original method
% newTimeUTC = flip((timeUTC(end):-expectedInc:timeUTC(1))'); % 2017-02-03 method

% Resample the data to evenly spaced increments
newActivityReading.timeOffset = interp1(activityReading.timeUTC,activityReading.timeOffset,newActivityReading.timeUTC,'nearest'); % 2017-02-06

varNames = activityReading.Properties.VariableNames(3:4);
for iVar = 1:numel(varNames)
    thisVar = varNames{iVar};
    
    % Resample the data to evenly spaced increments
    newVar = interp1(activityReading.timeUTC,activityReading.(thisVar),newActivityReading.timeUTC,'linear');
    
    % If there were large gaps replace the interpolated values with 0
    if nGap > 0
        for iGap = 1:nGap
            thisStart = gapStart(iGap);
            thisEnd = gapEnd(iGap);
            thisIdx = newActivityReading.timeUTC > thisStart & newActivityReading.timeUTC < thisEnd;
            newVar(thisIdx) = 0;
        end
    end
    
    newActivityReading.(thisVar) = newVar;
end

% Limit AI to 1
newActivityReading.activityIndex(newActivityReading.activityIndex > 1) = 1;



if unixFlag
    newActivityReading.timeUTC = posixtime(newActivityReading.timeUTC);
else
    newActivityReading.timeLocal = newActivityReading.timeUTC;
    newActivityReading.timeLocal.TimeZone = 'local';
end

end

