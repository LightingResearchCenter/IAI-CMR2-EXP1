function readingTable = CorrectTimestamps(readingTable)
%CORRECTTIMESTAMPS Summary of this function goes here
%   Detailed explanation goes here

dt = diff(readingTable.timeUTC);
epoch = mode(dt);
k = find(dt<0,1);

% Correct negative date slips
while ~isempty(k)
deltaFix = readingTable.timeUTC(k) + epoch - readingTable.timeUTC(k+1);

readingTable.timeUTC(k+1:end) = readingTable.timeUTC(k+1:end) + deltaFix;

dt = diff(readingTable.timeUTC);
k = find(dt<0,1);
end

% % Replace local time with corrected time
% readingTable.timeLocal = readingTable.timeUTC;
% readingTable.timeLocal.TimeZone = 'local';

end

