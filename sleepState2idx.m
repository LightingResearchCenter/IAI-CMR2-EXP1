function activityReading = sleepState2idx(sleep,activityReading)
%STATE2IDX Summary of this function goes here
%   Detailed explanation goes here

idxSleep   = false(size(activityReading.timeUTC));
idxAwake   = idxSleep;

nState = numel(sleep.sleepState);
for iState = 1:nState
    if iState ~= nState
        idxTemp = activityReading.timeUTC >= sleep.timeUTC(iState) & activityReading.timeUTC < sleep.timeUTC(iState+1);
    else % iState == nState
        idxTemp = activityReading.timeUTC >= sleep.timeUTC(iState);
    end
    
    switch sleep.sleepState{iState}
        case 'Sleeping'
            idxSleep   = idxTemp | idxSleep;
        case 'Awake'
            idxAwake   = idxTemp | idxAwake;
        otherwise
            error('Sleep state not recognized.')
    end
end

activityReading.idxSleep = idxSleep;
activityReading.idxAwake = idxAwake;

end

