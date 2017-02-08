function tf = LRCisAvail(unavailability,t1,t2,runTimeUTC)
%LRCISAVAIL Summary of this function goes here
%   Detailed explanation goes here

unavailStart = unavailability.startTimeUTC;
unavailEnd   = unavailStart + unavailability.durationSecs;

% Test that t1 and t2 do not overlap with any unavailable times
tf1 = all( (unavailEnd <= t1) | (unavailStart >= t2) );

% Test that t1 and t2 are not in the past
tf2 = (t1 >= runTimeUTC) & (t2 >= runTimeUTC);

tf = tf1 & tf2;

end

