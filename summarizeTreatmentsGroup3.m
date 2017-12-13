function summarizeTreatmentsGroup3
%SUMMARIZETREATMENTS Summarize treatments of all subjects

timestamp = datestr(now,'yyyy-mm-dd HHMM');

resetMatlab

%% Dependencies
addpath('C:\Users\jonesg5\Documents\GitHub\HealthyHomeBlackBox')
addpath('C:\Users\jonesg5\Documents\GitHub\HealthyHomeBlackBox\defines')


%% File paths
programDir = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data';
groupDir   = fullfile(programDir, 'Group_3'); % Subject group
tablesDir  = fullfile(groupDir,   'tables');   % Save location for tables

xlsxName = [timestamp, ' treatments.xlsx'];
xlsxPath = fullfile(tablesDir, xlsxName);

[arcDirs, subList] = getSubDirs(groupDir);

treatmentFiles = fullfile(arcDirs,'treatment.csv');


%% Iterate through treatment files
nArc = numel(treatmentFiles);
treatmentCollector = cell(size(treatmentFiles));
for iArc = 1:nArc
    % Read data from files
    thisTreatment = readtable(treatmentFiles{iArc});
    % Add subject ID to treatment
    thisTreatment.ID = repmat(subList(iArc),size(thisTreatment.startTime));
    % Copy treatments to collector
    treatmentCollector{iArc} = thisTreatment;
end

%% Process treatments
% Remove empty treatment files
idxEmpty = cellfun(@isempty, treatmentCollector);
treatmentCollector(idxEmpty) = [];
% Combine tables
Treatments = vertcat(treatmentCollector{:});
% Move ID to front
Treatments = [Treatments(:,6),Treatments(:,1:5)];
% Remove unnecessary columns
Treatments.startTime = [];
Treatments.subjectId = [];
Treatments.hubId = [];
% Convert humanTime to datetime
Treatments.start = datetime(Treatments.humanTime,'InputFormat','yyyy-MM-dd HH:mm','TimeZone','America/New_York');
Treatments.humanTime = [];
Treatments = unique(Treatments,'rows');
Treatments.session = repmat({'morning'},size(Treatments.start));
Treatments.session(hour(Treatments.start) >= 12) = {'afternoon'};

%% Save treatments to excel
writetable(Treatments, xlsxPath);
end


function resetMatlab
fclose('all');
close all
clear
clc
end


function [arcDirs, subList] = getSubDirs(groupDir)
phoneList   = {'A4D7', 'F900', '97BC'}';
subjectList = {'308',  '309',  '310'}';

subDirs    = fullfile(groupDir, phoneList);

arcDirs = cell(size(subDirs));
subList = cell(size(subDirs));
for iSub = 1:numel(subDirs)
    subListing = dir(fullfile(subDirs{iSub},'*_archive'));
    arcDirs{iSub} = fullfile(subDirs{iSub},{subListing.name}');
    subList{iSub} = repmat(subjectList(iSub),size(arcDirs{iSub}));
end

arcDirs = vertcat(arcDirs{:});
subList = vertcat(subList{:});

end

