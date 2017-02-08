function OutputStruct = wrapper(InputStruct,varargin)
%WRAPPER wrapper function for BLACKBOX
%   Parses inputs and outputs. Reads input data from file.
%
%   See also BLACKBOX.

%   Author(s): G. Jones,    2015-06-01
%   Copyright 2015 Rensselaer Polytechnic Institute. All rights reserved.

% Enable access to constants
% REPLACE with actual #define in C code
addpath('defines');

% Assign input
runTimeUTC              = InputStruct.runTimeUTC;
runTimeOffset           = InputStruct.runTimeOffset;
targetPhase             = InputStruct.targetPhase;
lightReadingPointer     = InputStruct.lightReadingPointer;
activityReadingPointer	= InputStruct.activityReadingPointer;
pacemakerPointer        = InputStruct.pacemakerPointer;

% Perform file IO REPLACE with native C functions
lightReading0	 = LRCread_lightReading(lightReadingPointer);
activityReading0 = LRCread_activityReading(activityReadingPointer);
pacemakerArray   = LRCread_pacemaker(pacemakerPointer);
lastPacemaker    = LRCtruncate_pacemaker(pacemakerArray);

% Keep just the needed variables from light reading
lightReading = struct(                          ...
    'timeUTC',      lightReading0.timeUTC,      ...
    'timeOffset',	lightReading0.timeOffset,   ...
    'cs',           lightReading0.cs            ...
    );

% Keep just the needed variables from activity reading
activityReading = struct(                               ...
    'timeUTC',          activityReading0.timeUTC,       ...
    'timeOffset',       activityReading0.timeOffset,    ...
    'activityIndex',	activityReading0.activityIndex  ...
    );

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% DELETE ME

if nargin > 1
    cropForDebug = varargin{1};
else
    cropForDebug = false;
end

if cropForDebug
    % Only use readings before runTimeUTC
    % For testing ONLY
    % Light Reading
    idxL = lightReading.timeUTC <= runTimeUTC;
    lightReading.timeUTC(~idxL) = [];
    lightReading.timeOffset(~idxL) = [];
    lightReading.cs(~idxL) = [];
    % Activity Reading
    idxA = lightReading.timeUTC <= runTimeUTC;
    activityReading.timeUTC(~idxA) = [];
    activityReading.timeOffset(~idxA) = [];
    activityReading.activityIndex(~idxA) = [];
end
% END of DELETE ME
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Call blackbox
[treatment,pacemaker,distanceToGoal] = blackbox(    ...
    runTimeUTC,runTimeOffset,targetPhase,      ...
    lightReading,activityReading,lastPacemaker      ...
    );

% Assign output
OutputStruct = struct(                  ...
    'treatment',        treatment,      ...
    'pacemaker',        pacemaker,      ...
    'distanceToGoal',   distanceToGoal	...
    );

end

