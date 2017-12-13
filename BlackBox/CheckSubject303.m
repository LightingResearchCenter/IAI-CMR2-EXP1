%% Reset
fclose('all');
close all
clear
clc

%% Dependencies
[cmr2Dir,~,~] = fileparts(pwd);
addpath(cmr2Dir,'defines','excludes');

%% Constants
targetPhase = 72313.49;

%% File paths
topDir	= '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data';
subDir	= fullfile(topDir,'303-97BC');
listing	= dir([subDir,filesep,'*archive']);
listing	= listing(:,listing.isdir);
lf      = fullfile(subDir,{listing.name}','lightReading.csv');
af      = fullfile(subDir,{listing.name}','activityReading.csv');
gf      = fullfile(subDir,{listing.name}','glassesState.csv');
sf      = fullfile(subDir,{listing.name}','sleepState.csv');
pf      = fullfile(subDir,{listing.name}','pacemaker.csv');

%% Pacemaker model loop
nDir = numel(lf);
varNames = {'runTimeUTC', 'runTimeOffset', 'version', 'model', 'x0', 'xc0', 't0', 'xn', 'xcn', 'tn'};  
pacemakerCollector = table([],[],{},{},[],[],[],[],[],[],'VariableNames',varNames);
firstRun = true;
for iDir = 3:nDir
    % Read files
    lightReading    = readtable(lf{iDir});
    activityReading = readtable(af{iDir});
    glasses         = readtable(gf{iDir});
    sleep           = readtable(sf{iDir});
    orgPacemaker    = readtable(pf{iDir});
    
    if isempty(lightReading) || isempty(activityReading)
        continue
    end
    
    if isempty(orgPacemaker)
        runTimeUTC = lightReading.timeUTC(end);
    else
        runTimeUTC = orgPacemaker.runTimeUTC(end);
    end
    
    % Correct timestamps
%     lightReading    = CorrectTimestamps(lightReading);
%     activityReading = CorrectTimestamps(activityReading);

    % Adjust data
    lightReading    = adjustCS(glasses,lightReading);
    activityReading = sleepState2idx(sleep,activityReading);
    
    if ~firstRun
        lastPacemaker = table2struct(pacemakerCollector(end,:));
    else
        lastPacemaker = table2struct(pacemakerCollector);
    end
    try
    [pacemaker] = blackbox(runTimeUTC,lightReading.timeOffset(end),targetPhase,table2struct(lightReading,'ToScalar',true),table2struct(activityReading,'ToScalar',true),lastPacemaker);
    pacemakerCollector = [pacemakerCollector;struct2table(pacemaker)];
    catch err
        display(err.message)
    end
    firstRun = false;
    display(['Loop ',num2str(iDir),' of ',num2str(nDir),' complete'])
end

[Lia,Lib] = ismembertol(pacemakerCollector.runTimeUTC,orgPacemaker.runTimeUTC,180,'DataScale',1);
pacemakerA = pacemakerCollector(Lia,:);
pacemakerB = orgPacemaker(Lib(Lib>0),:);

pacemakerCollector.tn_utc = datetime(pacemakerCollector.tn,'ConvertFrom','posixtime','TimeZone','UTC');
pacemakerCollector.tn_local = pacemakerCollector.tn_utc;
pacemakerCollector.tn_local.TimeZone = 'local';
pacemakerCollector.DLMO = Pacemaker2Phase(datenum(pacemakerCollector.tn_local),pacemakerCollector.xcn,pacemakerCollector.xn);

pacemakerCollector.DLMO(hours(pacemakerCollector.DLMO) < 6) = pacemakerCollector.DLMO(hours(pacemakerCollector.DLMO) < 6) + duration(24,0,0);
pacemakerCollector.runTimeUTC = datetime(pacemakerCollector.runTimeUTC,'ConvertFrom','posixtime','TimeZone','UTC');

orgPacemaker.tn_utc = datetime(orgPacemaker.tn,'ConvertFrom','posixtime','TimeZone','UTC');
orgPacemaker.tn_local = orgPacemaker.tn_utc;
orgPacemaker.tn_local.TimeZone = 'local';
orgPacemaker.DLMO = Pacemaker2Phase(datenum(orgPacemaker.tn_local),orgPacemaker.xcn,orgPacemaker.xn);

orgPacemaker.DLMO(hours(orgPacemaker.DLMO) < 6) = orgPacemaker.DLMO(hours(orgPacemaker.DLMO) < 6) + duration(24,0,0);
orgPacemaker.runTimeUTC = datetime(orgPacemaker.runTimeUTC,'ConvertFrom','posixtime','TimeZone','UTC');


andrew = readtable('Sub303DLMO_Every2HoursRev5_08Feb2017.xlsx');
andrew.time = datetime(andrew.time,'ConvertFrom','datenum','TimeZone','local');
andrew.DLMO = duration(andrew.DLMO*24,0,0);

plot(orgPacemaker.runTimeUTC,orgPacemaker.DLMO,'-o')
hold on
plot(pacemakerCollector.runTimeUTC,pacemakerCollector.DLMO,'-o')
plot(andrew.time,andrew.DLMO)

f = gcf;
f.Units = 'normalized';
f.Position = [0    0.0370    1.0000    8.5/11];

grid on
box off
axis tight
legend('App','Matlab - Geoff (Every Archive Dataset)','Matlab - Andrew (every 2-hours)')
ylabel('Time of DLMO')
xlabel('Runtime UTC')
title({'CMR 2 Exp 1';'Subject 303';'Comparison of Pacemaker Model DLMO estimates'})

% delta_DLMO = pacemakerB.DLMO - fix(pacemakerA.DLMO)
% delta_tn  = pacemakerB.tn  - pacemakerA.tn