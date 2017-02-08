function timeLocal = LRCutc2local(timeUTC,timeOffset)
%LRCUTC2LOCAL Convert from UTC time to local time
%   timeUTC and timeLocal is in seconds from January 1, 1970.
%   timeOffset is in hours.

timeLocal = timeUTC + timeOffset*60*60;

end

