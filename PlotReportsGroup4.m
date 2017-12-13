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
topDir = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data\Group_4';
plotsDir = fullfile(topDir,'plots');
listing = dir(fullfile(topDir,'subject*'));
subList = regexprep({listing.name}','subject (\d\d\d).*','$1');
subDirs = fullfile(topDir,{listing.name}');
recentDirs = cell(size(subList));
for iSub = 1:numel(subDirs)
    subListing = dir(fullfile(subDirs{iSub},'*_archive'));
    if ~isempty(subListing)
        [~,maxIdx] = max([subListing.datenum]);
        recentDirs{iSub} = fullfile(subDirs{iSub},subListing(maxIdx).name);
    end
end
% remove empty subjects
idxEmpty = cellfun(@isempty,recentDirs);
subList(idxEmpty) = [];
recentDirs(idxEmpty) = [];

lightFiles      = fullfile(recentDirs,'lightReading.csv');
activityFiles	= fullfile(recentDirs,'activityReading.csv');
glassesFiles	= fullfile(recentDirs,'glassesState.csv');
sleepFiles      = fullfile(recentDirs,'sleepState.csv');

%% Iterate through subjects
for iSub = 1:numel(subDirs)
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