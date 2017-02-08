%% Reset MATLAB
close all
clear
clc

addpath('excludes');

%% Set constants
pauseDuration	= 0;	% Pause time between loops in seconds
maxLoop         = 10^10; % Maximum number of loops
simDuration     = 2*3600;	% Duration of time to simulate in seconds
samplingInterval= 30;	% Simulated sampling interval in seconds
bedTime         = 22.5; % hours, 0 <= bedTime < 24
riseTime        = 6.5;  % hours, 0 <= wakeTime < 24
workStart       = 8.5;  % hours, 0 <= wakeTime < 24
workEnd         = 17;   % hours, 0 <= wakeTime < 24

%% Initialize files. Stored in temporary location.
[filePaths] = LRCinitTempFiles;

%% Initialize data and variables
% Get current UTC time and offset from system
[runTimeUTC,runTimeOffset] = getTime;
% Create initial set of simulated light and activity
[lightReading,activityReading] = simulateData(...
    runTimeUTC,runTimeOffset,simDuration,samplingInterval);
% Save simulated data to file
filePointers = LRCopen(filePaths,'a');
LRCappend_file(filePointers.lightReading,lightReading);
LRCappend_file(filePointers.activityReading,activityReading);
LRCclose(filePointers);

% Initialize input struct
InputStruct = struct(                                           ...
    'runTimeUTC',               runTimeUTC,                     ...
    'runTimeOffset',            runTimeOffset,                  ...
    'bedTime',                  bedTime,                        ...
    'riseTime',                 riseTime,                       ...
    'lightReadingPointer',      filePointers.lightReading,      ...
    'activityReadingPointer',   filePointers.activityReading,   ...
    'pacemakerPointer',         filePointers.pacemaker          ...
    );

%% Simulate multiple runs
% Create and initialize figure
[figureHandle,axisHandles,textHandle] = createFigure;

runflag = true;
counter = 0;
while runflag && counter <= maxLoop
    % Update simulated runtime
    runTimeUTC = lightReading.timeUTC(end);
    
    % Open the files for read only
    filePointers = LRCopen(filePaths,'r');
    
    % Update the input struct in case something has changed
    InputStruct.runTimeUTC              = runTimeUTC;
    InputStruct.runTimeOffset           = runTimeOffset;
    InputStruct.bedTime                 = bedTime;
    InputStruct.riseTime                = riseTime;
    InputStruct.lightReadingPointer     = filePointers.lightReading;
    InputStruct.activityReadingPointer	= filePointers.activityReading;
    InputStruct.pacemakerPointer        = filePointers.pacemaker;
    
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
    % RUN THE MODEL                    %
    OutputStruct = wrapper(InputStruct);
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
    
    % Close and reopen files for appending
    LRCclose(filePointers);
    LRCopen(filePaths,'a');
    
    % Append new pacemaker struct to file
    LRCappend_file(filePointers.pacemaker,OutputStruct.pacemaker);
    
    % Update graphics and UI
    updateFigure(axisHandles,textHandle,filePaths,OutputStruct,bedTime,riseTime,workStart,workEnd);
    pause(pauseDuration);
    
    % Generate simulated light and activity for next loop
    startTimeUTC = lightReading.timeUTC(end) + samplingInterval;
    [lightReading,activityReading] = simulateData(...
        startTimeUTC,runTimeOffset,simDuration,samplingInterval);
    LRCappend_file(filePointers.lightReading,lightReading);
    LRCappend_file(filePointers.activityReading,activityReading);
    
    % Close the files
    LRCclose(filePointers)
    
    % Increment the counter
    counter = counter + 1;
end

%% Close out and clean up
% Close the files
fclose('all');
% Prompt the user if they would like to save the files
[choice,options] = LRCdialogSaveTemp;
switch choice
    case options{1}
        % Prompt user for save path
        saveDir = uigetdir(pwd,'Select save location.');
        LRCmove(saveDir,filePaths)
    case options{2}
        % Permanently delete temporary files
        LRCdelete(filePaths);
    otherwise
        % Issue warning
        warning(LRCwarningTempFiles(filePaths));
end

display('The program has been stopped.');
