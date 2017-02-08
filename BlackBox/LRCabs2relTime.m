function relTime = LRCabs2relTime(absTime)
%LRCABS2RELTIME Convert absolute time to time of day
%   Input and output are in units of seconds

relTime = mod(absTime,86400);

end

