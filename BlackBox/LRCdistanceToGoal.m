function distanceToGoal = LRCdistanceToGoal(currentRefPhaseTime,targetPhase)
%LRCDISTANCETOGOAL Summary of this function goes here
%   Detailed explanation goes here

distanceToGoal = mod(currentRefPhaseTime,86400) - mod(targetPhase,86400); % seconds
if distanceToGoal < -12*60*60
    distanceToGoal = distanceToGoal + 24*60*60;
elseif distanceToGoal >= 12*60*60
    distanceToGoal = distanceToGoal - 24*60*60;
end

end

