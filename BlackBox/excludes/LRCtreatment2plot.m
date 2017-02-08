function [timeScene,scene] = LRCtreatment2plot(startTime,treatment,timeOffset)
%LRCTREATMENT2PLOT Summary of this function goes here
%   Detailed explanation goes here

if isempty(treatment.startTimeUTC)
    timeScene = [];
    scene = [];
    return;
end

startLocal = unix2datenum(LRCutc2local(treatment.startTimeUTC,timeOffset));
startLocal = startLocal(:);

inc  = 30/86400;
timeScene = startTime:inc:startTime+2;

durationDays = treatment.durationMins/60/24;
durationDays = durationDays(:);

endLocal = startLocal + durationDays;

treatmentState = false(size(timeScene));

for iStart = 1:numel(startLocal)
    thisState = timeScene >= startLocal(iStart) & timeScene < endLocal(iStart);
    treatmentState = treatmentState | thisState;
end

scene = zeros(size(timeScene));
scene(treatmentState) = 1;

end

