function acrophaseTime = LRCacrophaseAngle2Time(acrophaseAngle)
%LRCACROPHASEANGLE2TIME Summary of this function goes here
%   Detailed explanation goes here

% Time of day, in seconds, when acrophase occurs
acrophaseTime = mod(-acrophaseAngle/pi*43200,86400);

end

