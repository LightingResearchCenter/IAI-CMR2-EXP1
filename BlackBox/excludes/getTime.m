function [nowTimeUTC,nowTimeOffset] = getTime
%GETTIME Summary of this function goes here
%   Detailed explanation goes here

nowTimeUTC = java.lang.System.currentTimeMillis/1000;

javaTimeZoneObj = java.util.TimeZone.getDefault;
javaTimeZoneStr = matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(javaTimeZoneObj);
nowTimeOffsetMSStr = regexprep(javaTimeZoneStr,'.*offset=(-?\+?\d*),.*','$1');
nowTimeOffset = str2double(nowTimeOffsetMSStr)/(1000*60*60);
end

