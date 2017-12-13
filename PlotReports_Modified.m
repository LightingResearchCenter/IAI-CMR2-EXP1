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
topDir = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data';
groupDirs = fullfile(topDir,{'Modified Data'});
plotsDir = fullfile(topDir,'plots_v2');

for iGroup = 1:numel(groupDirs)
    thisGroup = groupDirs{iGroup};
    listing = dir(fullfile(thisGroup,'subject*'));
    subListTemp = regexprep({listing.name}','subject (\d\d\d).*','$1');
    subDirsTemp = fullfile(thisGroup,{listing.name}');
    recentDirsTemp = cell(size(subListTemp));
    for iSub = 1:numel(subDirsTemp)
        subListing = dir(fullfile(subDirsTemp{iSub},'*_archive'));
        if ~isempty(subListing)
            [~,maxIdx] = max([subListing.datenum]);
            recentDirsTemp{iSub} = fullfile(subDirsTemp{iSub},subListing(maxIdx).name);
        end
    end
    % remove empty subjects
    idxEmpty = cellfun(@isempty,recentDirsTemp);
    subListTemp(idxEmpty) = [];
    recentDirsTemp(idxEmpty) = [];
    
    if iGroup == 1
        subList    = subListTemp;
        subDirs    = subDirsTemp;
        recentDirs = recentDirsTemp;
    else
        subList    = vertcat(subList, subListTemp);
        subDirs    = vertcat(subDirs, subDirsTemp);
        recentDirs = vertcat(recentDirs, recentDirsTemp);
    end
end

lightFiles      = fullfile(recentDirs,'lightReading.csv');
activityFiles	= fullfile(recentDirs,'activityReading.csv');
glassesFiles	= fullfile(recentDirs,'glassesState.csv');
sleepFiles      = fullfile(recentDirs,'sleepState.csv');
deviceFiles     = fullfile(recentDirs,'device.csv');

%% Iterate through subjects
for iSub = 1:numel(subDirs)
    thisSub = subList{iSub};
    
    reportTitle = {'IAI-CMR2 Experiment 1';['Subject: ',thisSub]};
    
    lightReading    = ReadLog(lightFiles{iSub});
    activityReading = ReadLog(activityFiles{iSub});
    glasses         = ReadLog(glassesFiles{iSub});
    sleep           = ReadLog(sleepFiles{iSub});
    
    % lightReading = sortrows(lightReading);
    % activityReading = sortrows(activityReading);
    
    % Recompute CLA and CS from RGBC
    lightReading = rgbc2cla(lightReading);
    
    % Fill in gaps
    lightReading = LRCgapFillLightReading(lightReading,thisSub);
    activityReading = LRCgapFillActivityReading(activityReading);
    
    lightReading    = adjustCS(glasses,lightReading);
    activityReading = sleepState2idx(sleep,activityReading);
    
    obj = cmrgram(lightReading,activityReading,reportTitle);
    
    nObj = numel(obj);
    savePaths = cell(nObj,1);
    for iFig = 1:numel(obj)
        name = [timestamp,' subject ',thisSub,' sheet ',num2str(obj(iFig).PageNumber(1)),'.pdf'];
        savePaths{iFig} = fullfile(plotsDir,name);
        saveas(obj(iFig).Figure,savePaths{iFig})
        close(obj(iFig).Figure)
    end
    
    name = [timestamp,' subject ',thisSub,'.pdf'];
    savePathAll = fullfile(plotsDir,name);
    
    append_pdfs(savePathAll, savePaths{:});
    delete(savePaths{:});
    
end

winopen(plotsDir);