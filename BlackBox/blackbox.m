function [pacemaker] = blackbox(runTimeUTC,runTimeOffset,targetPhase,lightReading,activityReading,lastPacemaker) %#codegen
%BLACKBOX Create light treatment schedule and measure progress toward goal.
%
%   Inputs:
%   RUNTIMEUTC      time wrapper was called in UTC UNIX format
%   RUNTIMEOFFSET	offset of local time from UTC in hours at runtime
%   BEDTIME         time day in hours in local time
%   RISETIME        time day in hours in local time
%   LIGHTREADING	lightReading struct
%   ACTIVITYREADING	activityReading struct
%   PACEMAKERARRAY	pacemaker struct, with all entries
%
%   Outputs:
%   TREATMENT       treatment struct
%   PACEMAKER       pacemaker struct, single new entry
%   DISTANCETOGOAL	hours between current phase angle and target
%
%   See also LRCREAD_ACTIVITYREADING, LRCREAD_LIGHTREADING,
%   LRCREAD_PACEMAKER.

%   Author(s): G. Jones,    2015-05-21
%   	       A. Bierman,  2015-05-26
%   Copyright 2015 Rensselaer Polytechnic Institute. All rights reserved.

% Initialize outputs
treatment = struct(                         ...
    'n',            0,                      ...
    'startTimeUTC', double.empty(LRCtreatmentSize),	...
    'durationMins', double.empty(LRCtreatmentSize)	...
    );
pacemaker = struct(                     ...
    'runTimeUTC',       runTimeUTC,     ...
    'runTimeOffset',	runTimeOffset,	...
    'version',          {{LRCgetAppVer}},	...
    'model',            {{LRCmodel}},       ...
    'x0',               [],	...
    'xc0',              [],	...
    't0',               [],	...
    'xn',               [],	...
    'xcn',              [],	...
    'tn',               []	...
    );
distanceToGoal = [];

% Return empty results and exit if either data is empty
if isempty(lightReading.timeUTC) || isempty(activityReading.timeUTC)
    return;
end
% Return empty results and exit if less than 24 hours of data
lightDuration = lightReading.timeUTC(end) - lightReading.timeUTC(1);
activityDuration = activityReading.timeUTC(end) - activityReading.timeUTC(1);
if lightDuration < 86400 || activityDuration < 86400
    return
end



% Truncate data to not more than 10 days (defined by LRCreadingDuration)
lightReading    = LRCtruncate_lightReading(lightReading,LRCreadingDuration);
activityReading = LRCtruncate_activityReading(activityReading,LRCreadingDuration);

% Fill in any gaps in CS
[lightReading.timeUTC,lightReading.timeOffset,lightReading.cs] = LRCgapFill(lightReading.timeUTC,lightReading.timeOffset,lightReading.cs,LRClightSampleInc);


% Calculate activity acrophase
activityTimeLocal = LRCutc2local(activityReading.timeUTC,activityReading.timeOffset);
lightTimeLocal = LRCutc2local(lightReading.timeUTC,lightReading.timeOffset);
% Fit activity data with cosine function
[~,~,acrophaseAngle] = LRCcosinorFit(activityTimeLocal,activityReading.activityIndex);
acrophaseTime = LRCacrophaseAngle2Time(acrophaseAngle);

% Check if the pacemakerStruct has previous values
if ~LRCisValidPacemaker(lastPacemaker)
%     [t0LocalRel,x0,xc0] = refPhaseTime2StateAtTime(acrophaseTime,mod(activityTimeLocal(1),86400),'activityAcrophase');
%     % convert back to absolute UTC Unix time
%     t0Local = t0LocalRel + 86400*floor(activityTimeLocal(1)/86400);
%     t0 = LRClocal2utc(t0Local,activityReading.timeOffset(1));


    [t0LocalRel,x0,xc0] = refPhaseTime2StateAtTime(acrophaseTime,mod(lightTimeLocal(1),86400),'activityAcrophase');
    % convert back to absolute UTC Unix time
    t0Local = t0LocalRel + 86400*floor(lightTimeLocal(1)/86400);
    t0 = LRClocal2utc(t0Local,lightReading.timeOffset(1));
    
    lightReading.cs = lightReading.cs;
else
    t0  = lastPacemaker.tn;
    x0  = lastPacemaker.xn;
    xc0	= lastPacemaker.xcn;
%     t0Local = LRCutc2local(t0,activityReading.timeOffset(1));
    t0Local = LRCutc2local(t0,lightReading.timeOffset(1));
    t0LocalRel = LRCabs2relTime(t0Local);
    idx = lightReading.timeUTC > lastPacemaker.tn; % light readings recorded since last run
    lightReading.cs = lightReading.cs(idx);
end

% Advance pacemaker model solution to end of light data
[tnLocalRel,xn,xcn] = pacemakerModelRun(t0LocalRel,x0,xc0,LRClightSampleInc,lightReading.cs);

% Calculate pacemaker state from activity acrophase
[~,xAcrophase,xcAcrophase] = refPhaseTime2StateAtTime(acrophaseTime,mod(tnLocalRel,86400),'activityAcrophase');

% Calculate phase difference from pacemaker state variables
phaseDiff = LRCphaseDifference(xcn,xn,xcAcrophase,xAcrophase);

% If phase difference between activity acrophase and the pacemaker model is
% greater than phaseDiffMax then reset model to activity acrophase
if abs(phaseDiff) > LRCphaseDiffMax
%     idx = find(activityReading.timeUTC >= lastPacemaker.tn,1,'first'); % first activity reading recorded since last run
%     startTimeNewDataLocal = LRCutc2local(activityReading.timeUTC(idx),activityReading.timeOffset(idx)); % NEED TO CORRECT  switch to light time

    idx = find(lightReading.timeUTC >= lastPacemaker.tn,1,'first'); % first activity reading recorded since last run % 2017-02-06
    startTimeNewDataLocal = LRCutc2local(lightReading.timeUTC(idx),lightReading.timeOffset(idx)); % 2017-02-06
    
    startTimeNewDataRel = LRCabs2relTime(startTimeNewDataLocal);
    
    [t0LocalRel,x0,xc0] = refPhaseTime2StateAtTime(acrophaseTime,startTimeNewDataRel,'activityAcrophase');
    [tnLocalRel,xn,xcn] = pacemakerModelRun(t0LocalRel,x0,xc0,LRClightSampleInc,lightReading.cs);
end

% convert to absoulute Unix time (seconds since Jan 1, 1970)
tn = t0 + (tnLocalRel-t0LocalRel);

currentRefPhaseTime = stateAtTime2RefPhaseTime(tnLocalRel,xAcrophase,xcAcrophase);
% Calculate distance to goal phase from current phase
distanceToGoal = LRCdistanceToGoal(currentRefPhaseTime,targetPhase);

% Find unavailable times
% unavailability = LRCbed2unavail(targetPhase,riseTime,runTimeUTC,runTimeOffset);

% Calculate light treatment schedule
% treatment = createlightschedule(tn,xn,xcn,targetPhase,unavailability,runTimeUTC);

% Assign values to output
pacemaker.x0  = x0;
pacemaker.xc0 = xc0;
pacemaker.t0  = t0;
pacemaker.xn  = xn;
pacemaker.xcn = xcn;
pacemaker.tn  = tn;

end