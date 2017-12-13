function newLightReading = LRCgapFillLightReading(lightReading, subject)
%LRCGAPFILL Resample data to evenly spaced increments filling gaps with 0s.
%   expectedInc must be in the same units as timeUTC
%   timeUTC and cs must be vertical vectors with at least 2 entries

if ~isdatetime(lightReading.timeUTC(1))
    lightReading.timeUTC = datetime(lightReading.timeUTC,'ConvertFrom','posixtime','TimeZone','UTC');
    unixFlag = true;
else
    unixFlag = false;
end

expectedInc = duration(0, 0, 180);

newLightReading = table;

% Fix time stamps
[~,ia,~] = unique(lightReading.timeUTC,'last');
lightReading = lightReading(ia,:);

% Find the time between samples
sampleDiff = round(diff(lightReading.timeUTC)/expectedInc); % Multiples of increment

% Find large gaps between samples
gap = sampleDiff > 1; % Effectively true if sampleDiff is 2 or greater

gapStart = lightReading.timeUTC([gap;false]); % Start time of each gap
gapEnd = lightReading.timeUTC([false;gap]); % End time of each gap
nGap = numel(gapStart); % Number of gaps

% Create evenly spaced time array
newLightReading.timeUTC = (min(lightReading.timeUTC):expectedInc:max(lightReading.timeUTC))'; % Original method
% newTimeUTC = flip((timeUTC(end):-expectedInc:timeUTC(1))'); % 2017-02-03 method

% Resample the data to evenly spaced increments
newLightReading.timeOffset = interp1(lightReading.timeUTC,lightReading.timeOffset,newLightReading.timeUTC,'nearest'); % 2017-02-06

varNames = lightReading.Properties.VariableNames(3:8);
for iVar = 1:numel(varNames)
    thisVar = varNames{iVar};
    
    % Resample the data to evenly spaced increments
    newVar = interp1(lightReading.timeUTC,lightReading.(thisVar),newLightReading.timeUTC,'linear');
    
    % If there were large gaps replace the interpolated values with 0
    if nGap > 0
        for iGap = 1:nGap
            thisStart = gapStart(iGap);
            thisEnd = gapEnd(iGap);
            thisIdx = newLightReading.timeUTC > thisStart & newLightReading.timeUTC < thisEnd;
            newVar(thisIdx) = 0;
        end
    end
    
    newLightReading.(thisVar) = newVar;
end

switch subject
    case '306'
        newCS = 0.5;
        t1 = datetime(1495051565,'ConvertFrom','posixtime','TimeZone','UTC');
        t2 = datetime(1495062872,'ConvertFrom','posixtime','TimeZone','UTC');
        idx = newLightReading.timeUTC > t1 & newLightReading.timeUTC < t2;
        newLightReading.cs(idx) = newCS;
        newLightReading.cla(idx) = cs2cla(newCS);
    case '307'
        newCS = 0.7;
        t1 = datetime( ...
            [2017, 5, 12, 12,  0, 0; ...
            2017, 5, 15, 12,  0, 0; ...
            2017, 5, 16, 12,  0, 0; ...
            2017, 5, 17, 12,  0, 0; ...
            2017, 5, 18, 12,  0, 0; ...
            2017, 5, 22, 12,  0, 0; ...
            2017, 5, 23, 12,  0, 0; ...
            2017, 5, 24, 12,  0, 0; ...
            2017, 5, 25, 12,  0, 0; ...
            2017, 5, 26, 12,  0, 0; ...
            2017, 5, 29, 12, 15, 0; ...
            2017, 5, 31, 12,  0, 0; ...
            2017, 6,  1, 12,  0, 0; ...
            2017, 6,  2, 12,  0, 0], 'TimeZone', 'America/New_York');
        
        t2 = datetime( ...
            [2017, 5, 12, 13,  0, 0; ...
            2017, 5, 15, 13, 30, 0; ...
            2017, 5, 16, 13, 30, 0; ...
            2017, 5, 17, 13,  0, 0; ...
            2017, 5, 18, 12, 45, 0; ...
            2017, 5, 22, 13,  0, 0; ...
            2017, 5, 23, 13,  0, 0; ...
            2017, 5, 24, 13,  0, 0; ...
            2017, 5, 25, 13,  0, 0; ...
            2017, 5, 26, 13,  0, 0; ...
            2017, 5, 29, 12, 45, 0; ...
            2017, 5, 31, 13,  0, 0; ...
            2017, 6,  1, 13, 30, 0; ...
            2017, 6,  2, 13,  0, 0], 'TimeZone', 'America/New_York');
        
        for iT = 1:numel(t1)
            idx = newLightReading.timeUTC > t1(iT) & newLightReading.timeUTC < t2(iT);
            newLightReading.cs(idx) = newCS;
            newLightReading.cla(idx) = cs2cla(newCS);
        end
    case '310'
        newCS = 0.7;
        t1 = datetime( ...
            [2017, 7, 30, 14,  0, 0; ...
             2017, 8,  6, 15,  0, 0], 'TimeZone', 'America/New_York');
        
        t2 = datetime( ...
            [2017, 7, 30, 16,  0, 0; ...
             2017, 8,  6, 17, 30, 0], 'TimeZone', 'America/New_York');
        
        for iT = 1:numel(t1)
            idx = newLightReading.timeUTC > t1(iT) & newLightReading.timeUTC < t2(iT);
            newLightReading.cs(idx) = newCS;
            newLightReading.cla(idx) = cs2cla(newCS);
        end
    case '312'
        newCS = 0.7;
        t1 = datetime( ...
            [2017,  9, 20, 11,  0, 0; ...
             2017,  9, 22, 10, 15, 0; ...
             2017,  9, 23, 12,  0, 0; ...
             2017,  9, 30, 11, 45, 0; ...
             2017, 10,  7, 12, 30, 0; ...
             2017, 10,  9, 12, 45, 0], 'TimeZone', 'America/New_York');
        
        t2 = datetime( ...
            [2017,  9, 20, 12,  0, 0; ...
             2017,  9, 22, 12,  0, 0; ...
             2017,  9, 23, 13,  0, 0; ...
             2017,  9, 30, 12, 30, 0; ...
             2017, 10,  7, 13, 45, 0; ...
             2017, 10,  9, 13, 45, 0], 'TimeZone', 'America/New_York');
        
        for iT = 1:numel(t1)
            idx = newLightReading.timeUTC > t1(iT) & newLightReading.timeUTC < t2(iT);
            newLightReading.cs(idx) = newCS;
            newLightReading.cla(idx) = cs2cla(newCS);
        end
end

if unixFlag
    newLightReading.timeUTC = posixtime(newLightReading.timeUTC);
else
    newLightReading.timeLocal = newLightReading.timeUTC;
    newLightReading.timeLocal.TimeZone = 'local';
end

end

