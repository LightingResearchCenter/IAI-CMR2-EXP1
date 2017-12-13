%% Reset Matlab
close all
clear
clc


%% File paths
topDir = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data';
groupDir = fullfile(topDir,'Modified Data');
plotsDir = fullfile(topDir,'plots_v2');

listing = dir(fullfile(groupDir,'subject*'));
subList = regexprep({listing.name}','subject (\d\d\d).*','$1');
subDirs = fullfile(groupDir,{listing.name}');
recentDirs = cell(size(subList));
for iSub = 1:numel(subDirs)
    subListing = dir(fullfile(subDirs{iSub},'*_archive'));
    if ~isempty(subListing)
        fileDates = datetime(regexprep({subListing.name}','...._(\d\d\d\d)_(\d\d)_(\d\d)_(\d\d)_(\d\d)_(\d\d)_archive','$1-$2-$3 $4:$5:$6'));
        [~,maxIdx] = max(fileDates);
        recentDirs{iSub} = fullfile(subDirs{iSub},subListing(maxIdx).name);
    end
end
% remove empty subjects
idxEmpty = cellfun(@isempty,recentDirs);
subList(idxEmpty) = [];
recentDirs(idxEmpty) = [];

lightFiles   = fullfile(recentDirs,'lightReading.csv');
glassesFiles = fullfile(recentDirs,'glassesState.csv');

%% Initialize figure
h = figure;
h.Units = 'normalized';
h.Position = [0 0 1 1];

%% Iterate through subjects
nSub = numel(subList);
dlmoCollector = table;
dlmoCollector.subject_id = subList;

for iSub = 1:nSub
    % Read data from files
    lightReading = ReadLog(lightFiles{iSub});
    glasses      = ReadLog(glassesFiles{iSub});
    
    % Recompute CLA and CS from RGBC
    lightReading2015 = rgbc2cla(lightReading,'2015');
    lightReading2016 = rgbc2cla(lightReading,'2016');
    
    % Adjust for glasses
    lightReading2015 = adjustCS(glasses,lightReading2015);
    lightReading2016 = adjustCS(glasses,lightReading2016);
    
    % Substitute machine epsilon for zero
    lightReading.cla(lightReading.cla==0) = eps;
    lightReading2015.cla(lightReading2015.cla==0) = eps;
    lightReading2016.cla(lightReading2016.cla==0) = eps;
    
    claRatio2015 = lightReading2015.cla./lightReading.cla;
    claRatio2016 = lightReading2016.cla./lightReading.cla;
    claRatio2015_2016 = lightReading2016.cla./lightReading2015.cla;
    
    clf(h)
    subplot(4,1,1)
    semilogy(lightReading.timeLocal, lightReading.cla)
    ylabel('CLA')
    set(gca, 'YLim', [10^(-1) 10^5])
    title({subList{iSub}; 'CLA on file'})
    
    subplot(4,1,2)
    plot(lightReading.timeLocal, claRatio2015)
    ylabel('Ratio')
    title({subList{iSub}; '2015/File'})
    set(gca, 'YLim', [0 1.5])
    
    subplot(4,1,3)
    plot(lightReading.timeLocal, claRatio2016)
    ylabel('Ratio')
    title({subList{iSub}; '2016/File'})
    set(gca, 'YLim', [0 1.5])
    
    subplot(4,1,4)
    plot(lightReading.timeLocal, claRatio2015_2016)
    ylabel('Ratio')
    title({subList{iSub}; '2016/2015'})
    set(gca, 'YLim', [0 1.5])
    
    saveas(h,fullfile(plotsDir,['CLAcheck_',subList{iSub},'.jpg']))
end
close(h)

winopen(plotsDir)