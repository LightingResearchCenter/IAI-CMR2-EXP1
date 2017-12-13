%% Reset
fclose('all');
close all
clear
clc

%% File paths
topDir = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data';

sub300  = '300-43DF\43DF_2017_01_11_10_06_04_archive';      % last
sub301  = '301-A4D7\A4D7_2017_01_04_09_13_14_archive';      % last
sub302  = '302-0780-F900\F900_2017_01_13_06_45_58_archive';	% last
sub303  = '303-97BC\97BC_2017_01_13_08_12_00_archive';      % last
subDirs = {sub300,sub301,sub302,sub303}';

lightFiles      = fullfile(topDir,subDirs,'lightReading.csv');
activityFiles	= fullfile(topDir,subDirs,'activityReading.csv');
glassesFiles	= fullfile(topDir,subDirs,'glassesState.csv');
sleepFiles      = fullfile(topDir,subDirs,'sleepState.csv');
%% 
subList = {'300','301','302','303'}';

for iSub = 3
lf = lightFiles{iSub};
af = activityFiles{iSub};
gf = glassesFiles{iSub};
sf = sleepFiles{iSub};
reportTitle = ['Subject: ',subList{iSub}];

lightReading    = ReadLog(lf);
activityReading = ReadLog(af);
glasses         = ReadLog(gf);
sleep           = ReadLog(sf);


lightReading    = CorrectTimestamps(lightReading);
activityReading = CorrectTimestamps(activityReading);

lightReading    = adjustCS(glasses,lightReading);
activityReading = sleepState2idx(sleep,activityReading);

[tEnd, acrophase] = MovingAcrophase(activityReading,10,1/24);
  
plot(tEnd,acrophase,'-o')

[~,I] = min(abs(tEnd-datetime(2016,12,30,17,0,0,'TimeZone','local')));
text(tEnd(I),acrophase(I),['Intervention Start: ',num2str(acrophase(I),'%.1f')])

[~,I] = min(abs(tEnd-datetime(2017,01,13,17,0,0,'TimeZone','local')));
text(tEnd(I),acrophase(I),['Intervention End: ',num2str(acrophase(I),'%.1f')])

[M,I] = max(acrophase);
text(tEnd(I),M,['MAX: ',num2str(M,'%.1f')])

[M,I] = min(acrophase);
text(tEnd(I),M,['MIN: ',num2str(M,'%.1f')])

grid on
box off
ax = gca;
ax.TickDir = 'out';
% ax.YLim = [6,10.5];
ax.XTick = ax.XLim(1):ax.XLim(2);
ax.XTickLabelRotation = 45;
end