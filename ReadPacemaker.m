function t = ReadPacemaker(filePath)
%READPACEMAKER Summary of this function goes here
%   Detailed explanation goes here

%% Read file
t = readtable(filePath);

%% Convert Unix times to Datetime
t.runTimeLocal = datetime(t.runTimeUTC,'ConvertFrom','posixtime','TimeZone','UTC');
t.t0 = datetime(t.t0,'ConvertFrom','posixtime','TimeZone','UTC');
t.tn = datetime(t.tn,'ConvertFrom','posixtime','TimeZone','UTC');

t.t0.TimeZone = 'local';
t.tn.TimeZone = 'local';

%% Normalize x and xc
% t.x0(t.x0>1) = 1;
% t.x0(t.x0<-1) = -1;
% t.xc0(t.xc0>1) = 1;
% t.xc0(t.xc0<-1) = -1;
% 
% t.xn(t.xn>1) = 1;
% t.xn(t.xn<-1) = -1;
% t.xcn(t.xcn>1) = 1;
% t.xcn(t.xcn<-1) = -1;

end

