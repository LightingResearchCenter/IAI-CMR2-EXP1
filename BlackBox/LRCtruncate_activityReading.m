function activityReadingTrunc = LRCtruncate_activityReading(acyivityReading,durationSec)
%LRCTRUNCATE_ACTIVITYREADING Truncate activityReading
%   Discards readings older than the specified duration. One of the fields
%   must be timeUTC. All fields must be vectors of equal length.

cutoffTime = max(acyivityReading.timeUTC) - durationSec;
idx = acyivityReading.timeUTC >= cutoffTime;

activityReadingTrunc = struct(                          ...
    'timeUTC',      acyivityReading.timeUTC(idx),       ...
    'timeOffset',   acyivityReading.timeOffset(idx),	...
    'activityIndex',acyivityReading.activityIndex(idx)	...
    );

end

