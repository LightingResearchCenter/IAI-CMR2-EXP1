%% Reset
fclose('all');
close all
clear
clc

%%
timestamp = datestr(now,'yyyy-mm-dd HHMM');

%% Dependencies
addpath('C:\Users\jonesg5\Documents\GitHub\d12pack')
addpath('C:\Users\jonesg5\Documents\GitHub\export_fig')

%% File paths
topDir = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data\Group_3';
plotsDir = fullfile(topDir,'plots');
phoneList = {'A4D7', 'F900', '97BC'}';
subList   = {'308',  '309',  '310'}';
phoneDirs = fullfile(topDir,phoneList);
recentDirs = cell(size(phoneDirs));
for iSub = 1:numel(phoneDirs)
    subListing = dir(fullfile(phoneDirs{iSub},'*_archive'));
    if ~isempty(subListing)
        [~,maxIdx] = max([subListing.datenum]);
        recentDirs{iSub} = fullfile(phoneDirs{iSub},subListing(maxIdx).name);
    end
end
% remove empty subjects
idxEmpty = cellfun(@isempty,recentDirs);
phoneList(idxEmpty) = [];
recentDirs(idxEmpty) = [];

lightFiles      = fullfile(recentDirs,'lightReading.csv');
activityFiles	= fullfile(recentDirs,'activityReading.csv');
glassesFiles	= fullfile(recentDirs,'glassesState.csv');
sleepFiles      = fullfile(recentDirs,'sleepState.csv');

%% Iterate through subjects
for iSub = 1:numel(phoneDirs)
reportTitle = {'IAI-CMR2 Experiment 1';['Subject: ',subList{iSub}]};

lightReading    = ReadLog(lightFiles{iSub});
activityReading = ReadLog(activityFiles{iSub});
glasses         = ReadLog(glassesFiles{iSub});
sleep           = ReadLog(sleepFiles{iSub});

% lightReading = sortrows(lightReading);
% activityReading = sortrows(activityReading);

lightReading    = adjustCS(glasses,lightReading);
activityReading = sleepState2idx(sleep,activityReading);

obj = cmrgram(lightReading,activityReading,reportTitle);

nObj = numel(obj);
savePaths = cell(nObj,1);
for iFig = 1:numel(obj)
    name = [timestamp,' subject ',subList{iSub},' sheet ',num2str(obj(iFig).PageNumber(1)),'.pdf'];
    savePaths{iFig} = fullfile(plotsDir,name);
    saveas(obj(iFig).Figure,savePaths{iFig})
    close(obj(iFig).Figure)
end

name = [timestamp,' subject ',subList{iSub},'.pdf'];
savePathAll = fullfile(plotsDir,name);

append_pdfs(savePathAll, savePaths{:});
delete(savePaths{:});

end

winopen(plotsDir);