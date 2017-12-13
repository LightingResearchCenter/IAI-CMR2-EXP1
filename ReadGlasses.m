function t = ReadGlasses(filePath)
%READGLASSES Summary of this function goes here
%   Detailed explanation goes here

%% Read file
t = readtable(filePath);

%% Convert Unix times to Datetime
t.timeUTC = datetime(t.timeUTC,'ConvertFrom','posixtime','TimeZone','UTC');

t.timeLocal = t.timeUTC;
t.timeLocal.TimeZone = 'local';

end

