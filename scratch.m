%% Reset
fclose('all');
close all
clear
clc

%% Dependecies
[githubDir,~,~] = fileparts(pwd);
d12packDir = fullfile(githubDir,'d12pack');
addpath(d12packDir);

%%
f300 = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data\300-43DF\43DF_2017_01_11_10_06_04_archive\pacemaker.csv';
f301 = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data\301-A4D7\A4D7_2017_01_04_09_13_14_archive\pacemaker.csv';
f302 = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data\302-0780-F900\F900_2017_01_13_06_45_58_archive\pacemaker.csv';
f303 = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data\303-97BC\97BC_2017_01_13_08_12_00_archive\pacemaker.csv';

% f303b = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data\303-97BC\97BC_2017_01_09_07_48_31_archive\pacemaker.csv';

t300 = readtable(f300);
t301 = readtable(f301);
t302 = readtable(f302);
t303 = readtable(f303);
% t303 = ReadPacemaker(f303b);

%%
t300 = AnalyzeData(t300);
t301 = AnalyzeData(t301);
t302 = AnalyzeData(t302);
t303 = AnalyzeData(t303);


%% Plot data
%  figure
% PlotData(t303,'303')

r = d12pack.report;
r.Title = 'CMR 2, Experiment 1, Pacemaker Model';
r.Type = '';
ax = axes(r.Body);
subplot(ax)

subplot(4,1,1)
PlotData(t300,'300')

subplot(4,1,2)
PlotData(t301,'301')

subplot(4,1,3)
PlotData(t302,'302')

subplot(4,1,4)
PlotData(t303,'303')

L = findobj(r.Body.Children,'Type','Legend');
for iL = 1:numel(L)
    L(iL).String{2} = 'fit';
    L(iL).FontSize = 6;
    L(iL).Position(1) = L(iL).Position(1)+0.037;
    L(iL).Position(2) = L(iL).Position(2)+0.035+L(iL).Position(4);
end

saveas(r.Figure,'Delta-DLMO predictions2.pdf')

% 
% t = table;
% t.tn = t302.tn;
% t.xcn = t302.xcn;
% t.xn = t302.xn;
% t.DLMO = t302.DLMO;
% t = unique(t,'rows');
% 
% 
% figure
% [x,y] = pol2cart(t.DLMO*pi/12,ones(size(t.DLMO)));
% plot(x,y,'-o')
% 
% text(x,y,datestr(t.tn,'mm/dd HH:MM'))
% % text(t.xn,t.xcn-0.05,num2str(mod(-atan2(t.xcn,-t.xn),2*pi)))
% 
% 
% ax = gca;
% 
% theta = 0:0.01:2*pi;
% rho = ones(size(theta));
% [x,y] = pol2cart(theta,rho);
% 
% hold
% plot(x,y)
% 
% axis square
% axis equal
% 
% 
% 
% % figure
% % plot(t300.xcn,t300.xn,'-o')
% % ax = gca;
% % 
% % theta = 0:0.01:2*pi;
% % rho = ones(size(theta));
% % [x,y] = pol2cart(theta,rho);
% % 
% % hold
% % plot(x,y)
% % 
% % axis square
% % 
% % ax.XLim = [-1.5,1.5];
% % ax.YLim = [-1.5,1.5];
% 
% 
% 
