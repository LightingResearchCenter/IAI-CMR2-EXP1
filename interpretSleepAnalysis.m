%% Reset MATLAB
fclose('all');
close all
clear
clc

%% Generate timestamp
timestamp = datestr(now,'yyyy-mm-dd HHMM');

%% File paths
programDir = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data';
groupDir   = fullfile(programDir, 'Group_2'); % Subject group
tablesDir  = fullfile(groupDir,   'tables');  % Save location for tables
plotsDir   = fullfile(groupDir,   'plots');   % Save location for plots

%% Find most recent sleep analysis results
listing = dir(fullfile(tablesDir,'*sleep analysis.mat'));
[~, idx] = max(vertcat(listing.datenum));
matPath = fullfile(tablesDir,listing(idx).name);

%% Load sleep analysis data from file
tmp = load(matPath,'P');
t = tmp.P;


%% Convert text values to categorical arrays
t.subject  = categorical(t.subject,unique(t.subject),'Ordinal',true);
t.protocol = categorical(t.protocol,{'baseline','intervention'},'Ordinal',true);

%% 

%% Plot
plot(t.protocol,t.sleepEfficiency,'.')