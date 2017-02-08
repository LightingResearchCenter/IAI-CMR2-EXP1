function [newTimeUTC,newOffset,newCs] = LRCgapFill(timeUTC,timeOffset,cs,expectedInc)
%LRCGAPFILL Resample data to evenly spaced increments filling gaps with 0s.
%   expectedInc must be in the same units as timeUTC
%   timeUTC and cs must be vertical vectors with at least 2 entries

% Find the time between samples
sampleDiff = round(diff(timeUTC)/expectedInc); % Multiples of increment

% Find large gaps between samples
gap = sampleDiff > 1; % Effectively true if sampleDiff is 2 or greater

gapStart = timeUTC([gap;false]); % Start time of each gap
gapEnd = timeUTC([false;gap]); % End time of each gap
nGap = numel(gapStart); % Number of gaps

% Create evenly spaced time array
newTimeUTC = (timeUTC(1):expectedInc:timeUTC(end))'; % Original method
% newTimeUTC = flip((timeUTC(end):-expectedInc:timeUTC(1))'); % 2017-02-03 method

% Resample the data to evenly spaced increments
newCs = interp1(timeUTC,cs,newTimeUTC,'linear');
newOffset = interp1(timeUTC,timeOffset,newTimeUTC,'nearest'); % 2017-02-06

% If there were large gaps replace the interpolated values with 0
if nGap > 0
    for iGap = 1:nGap
        thisStart = gapStart(iGap);
        thisEnd = gapEnd(iGap);
        thisIdx = newTimeUTC > thisStart & newTimeUTC < thisEnd;
        newCs(thisIdx) = 0;
    end
end

end

