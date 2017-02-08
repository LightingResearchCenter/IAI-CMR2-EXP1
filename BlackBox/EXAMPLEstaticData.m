%% Reset MATLAB
close all
clear
clc

%%
addpath('excludes');

%% Initialize file paths
testDir = '97BC_2017_01_13_08_12_00_archive';
filePaths = struct(             ...
    'lightReading',     [testDir,filesep,'lightReading.csv'],	...
    'activityReading',	[testDir,filesep,'activityReading.csv'],	...
    'pacemaker',        [testDir,filesep,'pacemaker.csv']	...
    );
pacemakerTemplate = [testDir,filesep,'pacemakerTemplate.csv'];
pacemakerV1 = [testDir,filesep,'pacemakerV1.csv'];
treatmentPath = [testDir,filesep,'treatment.csv'];
treatmentTemplate = [testDir,filesep,'treatmentTemplate.csv'];

if exist(filePaths.pacemaker,'file') == 2
    % Delete existing pacemaker file
    delete(filePaths.pacemaker);
end
% Create a copy of the pacemaker template and rename it
copyfile(pacemakerTemplate,filePaths.pacemaker);

%% Set constants
t = readtable(pacemakerV1);
targetPhase	  = t.targetPhase(1);
runTimeUTC	  = t.tn;
runTimeOffset = t.runTimeOffset;
cropForDebug  = true;

%% Simulate running the pacemaker blackbox at each of the run times
for iRun = 1:numel(runTimeUTC)
    
    if exist(treatmentPath,'file') == 2
        % Delete existing treatment file
        delete(treatmentPath);
    end
    % Create a copy of the treatment template and rename it
    copyfile(treatmentTemplate,treatmentPath);

    % Open the files for read only
    filePointers = LRCopen(filePaths,'rt');

    % Initialize input struct
    InputStruct = struct(                                           ...
        'runTimeUTC',               runTimeUTC(iRun),               ...
        'runTimeOffset',            runTimeOffset(iRun),            ...
        'targetPhase',              targetPhase,                    ...
        'lightReadingPointer',      filePointers.lightReading,      ...
        'activityReadingPointer',   filePointers.activityReading,   ...
        'pacemakerPointer',         filePointers.pacemaker          ...
        );

    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
    % RUN THE MODEL                    %
    OutputStruct = wrapper(InputStruct,cropForDebug);
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %

    % Close the files
    fclose('all');

    % Reopen the pacemaker file for appending
    fid = fopen(filePaths.pacemaker,'at');
    % Append new pacemaker struct to file
    LRCappend_file(fid,OutputStruct.pacemaker);
    fclose(fid);
    
    
    % Format treatment for output
    treatment = struct;
    treatment.startTime = OutputStruct.treatment.startTimeUTC;
    treatment.durationMins = OutputStruct.treatment.durationMins;
    treatment.subjectId = repmat({'geoff'},size(treatment.startTime));
    treatment.hubId = repmat({'debug'},size(treatment.startTime));
    
    % Reopen the treatment file for appending
    fid = fopen(treatmentPath,'at');
    % Append new pacemaker struct to file
    LRCappend_file(fid,treatment);
    fclose(fid);
    
end

%% Compare MATLAB pacemaker to that from the App
% Open MATLAB generated pacemaker file
fid = fopen(filePaths.pacemaker,'rt');
% Read contents of MATLAB pacemaker
pacemakerArrayMat = LRCread_pacemaker(fid);
fclose(fid);
% Open App generated pacemaker file
fid = fopen(pacemakerV1,'rt');
% Read contents of App pacemaker
pacemakerArrayV1 = LRCread_pacemaker(fid);
fclose(fid);

% Calculate delta for all numeric variables
% delta = MATLAB Result - V1 Result
pacemakerDeltaStruct = struct;
varNames = fieldnames(pacemakerArrayMat);
for iVar = 1:numel(varNames)
    thisVar = varNames{iVar};
    if isnumeric(pacemakerArrayMat.(thisVar)) && isnumeric(pacemakerArrayV1.(thisVar))
        pacemakerDeltaStruct.(thisVar) = pacemakerArrayMat.(thisVar) - pacemakerArrayV1.(thisVar);
    end
end

pacemakerDelta = [fieldnames(pacemakerDeltaStruct)';num2cell(cell2mat(struct2cell(pacemakerDeltaStruct)'))];
display('pacemakerDelta = MATLAB Pacemaker - MATLAB/C v1 Pacemaker');
display(pacemakerDelta);

