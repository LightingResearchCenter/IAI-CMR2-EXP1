function lightReadingTrunc = LRCtruncate_lightReading(lightReading,durationSec)
%LRCTRUNCATE_LIGHTREADING Truncate lightReading
%   Discards readings older than the specified duration. One of the fields
%   must be timeUTC. All fields must be vectors of equal length.

cutoffTime = max(lightReading.timeUTC) - durationSec;
idx = lightReading.timeUTC >= cutoffTime;

lightReadingTrunc = struct(                         ...
    'timeUTC',      lightReading.timeUTC(idx),      ...
    'timeOffset',   lightReading.timeOffset(idx),   ...
    'cs',           lightReading.cs(idx)            ...
    );

end

