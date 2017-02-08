function TF = LRCisNewData(lightReading,activityReading,lastPacemaker)
%LRCISNEWDATA Check if there are new readings
%   Detailed explanation goes here

% If there are pacemaker parameters check for data newer than tn
if LRCisValidPacemaker(lastPacemaker)
    % Count the number of readings since tn
    nCs = sum(lightReading.timeUTC    > lastPacemaker.tn);
    nAi = sum(activityReading.timeUTC > lastPacemaker.tn);
    
else % There are no valid pacemaker parameters
    % Count the number of readings
    nCs = numel(lightReading.timeUTC);
    nAi = numel(activityReading.timeUTC);
    
end

% Check that there are at least 2 new readings for both AI & CS
TF = all([nCs,nAi] >= 2);

end
