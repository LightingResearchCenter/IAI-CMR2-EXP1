function timeUTC = LRClocal2utc(timeLocal,timeOffset)
%LRCLOCAL@UTC Convert from local time to UTC time
%   timeUTC and timeLocal is in seconds from January 1, 1970.
%   timeOffset is in hours.

timeUTC = timeLocal - timeOffset*60*60;

end

