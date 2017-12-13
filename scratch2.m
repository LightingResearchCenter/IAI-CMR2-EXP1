fclose('all');
close all
clear
clc

addpath('C:\Users\jonesg5\Documents\GitHub\HealthyHomeBlackBox')
addpath('C:\Users\jonesg5\Documents\GitHub\HealthyHomeBlackBox\defines')

lf303b = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data\303-97BC\97BC_2017_01_09_07_48_31_archive\lightReading.csv';

gf303b = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data\303-97BC\97BC_2017_01_09_07_48_31_archive\glassesState.csv';

lightReading = readtable(lf303b);
glasses = readtable(gf303b);

lightReading = adjustCS(glasses,lightReading);

% Truncate data to not more than 10 days (defined by LRCreadingDuration)
lightReading    = LRCtruncate_lightReading(lightReading,LRCreadingDuration);

% Fill in any gaps in CS
[lightReading.timeUTC,lightReading.cs] = LRCgapFill(lightReading.timeUTC,lightReading.cs,LRClightSampleInc);

t0  = 1483122445;
x0  = 0.02;
xc0	= 1.05;
t0Local = LRCutc2local(t0,lightReading.timeOffset(1));
t0LocalRel = LRCabs2relTime(t0Local);
idx = lightReading.timeUTC > t0; % light readings recorded since last run
newCS = lightReading.cs(idx);
% newCS = newCS(2:end-1);

% Advance pacemaker model solution to end of light data
[tnLocalRel,xn,xcn] = pacemakerModelRun(t0LocalRel,x0,xc0,LRClightSampleInc,newCS);

% convert to absoulute Unix time (seconds since Jan 1, 1970)
tn = t0 + (tnLocalRel-t0LocalRel);

xn = fix(xn*100)/100;
xcn = fix(xcn*100)/100;

tn_expected = 1483965745;
xn_expected = -0.34;
xcn_expected = 0.95;

tn_error = tn-tn_expected;
xn_error = xn-xn_expected;
xcn_error = xcn-xcn_expected;

display(tn)
display(tn_error)
display(xn)
display(xn_error)
display(xcn)
display(xcn_error) 

