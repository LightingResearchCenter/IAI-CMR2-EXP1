function unavailability = LRCbed2unavail(bedTime,riseTime,runTimeUTC,runTimeOffset)
%LRCBED2UNAVAIL Summary of this function goes here
%   Detailed explanation goes here

% Calculate the duration of time in bed in hours
if bedTime > riseTime
    bedDurationHrs = 24 - bedTime + riseTime;
elseif bedTime < riseTime
    bedDurationHrs = riseTime - bedTime;
else
    error('The values for bedTime and riseTime must be different.');
end

% Convert local bed time in hours to UTC time in seconds
bedTimeUTC = mod(LRClocal2utc(bedTime*60*60,runTimeOffset),86400);

% Create bed date and times for several days in the future
days = ((0:LRCtreatmentPlanLength+1)*86400)';
startDate = runTimeUTC - mod(runTimeUTC,86400);
startTimeUTC = startDate + days + bedTimeUTC;

% Convert duration to seconds and replicate
durationSecs = repmat(bedDurationHrs*60*60,size(startTimeUTC));

unavailability = struct(            ...
    'startTimeUTC', startTimeUTC,	...
    'durationSecs', durationSecs	...
    );

end

