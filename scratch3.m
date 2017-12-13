fclose('all');
close all
clear
clc

lightPath = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data\300-43DF\43DF_2017_01_11_10_06_04_archive\lightReading.csv';
% lightPath = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data\301-A4D7\A4D7_2017_01_04_09_13_14_archive\lightReading.csv';
% lightPath = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data\302-0780-F900\F900_2017_01_13_06_45_58_archive\lightReading.csv';
% lightPath = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data\303-97BC\97BC_2017_01_13_08_12_00_archive\lightReading.csv';

glassesPath = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data\300-43DF\43DF_2017_01_11_10_06_04_archive\glassesState.csv';


light = ReadLight2(lightPath);
light2 = sortrows(light,1);
% glasses = ReadGlasses(glassesPath);
% 
% [idxNone,idxBlue,idxOrange] = state2idx(glasses,light);
% [CLA,CS] = adjustCS(light.cla,idxBlue,idxOrange);
% plot(light.timeUTC,[light.cs]);%,CS])

dt = mode(diff(light.timeLocal));
t2 = light.timeLocal(1):dt:light.timeLocal(1)+dt*(numel(light.cs)-1);

figure
subplot(2,1,1)
plot(light2.timeLocal,light2.cs,'.-');
ylabel('CS')
xlim([t2(1),t2(end)])
title('Data Sorted by Date Time Stamp')


subplot(2,1,2)
plot(t2,light.cs,'.-');
ylabel('CS')
xlim([t2(1),t2(end)])
title('Data Sorted by Order in File')