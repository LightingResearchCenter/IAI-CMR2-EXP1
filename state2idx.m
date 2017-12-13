function [idxNone,idxBlue,idxOrange] = state2idx(glasses,light)
%STATE2IDX Summary of this function goes here
%   Detailed explanation goes here

idxNone   = false(size(light.timeUTC));
idxBlue   = idxNone;
idxOrange = idxNone;

nState = numel(glasses.glassesState);
for iState = 1:nState
    if iState ~= nState
        idxTemp = light.timeUTC >= glasses.timeUTC(iState) & light.timeUTC < glasses.timeUTC(iState+1);
    else % iState == nState
        idxTemp = light.timeUTC >= glasses.timeUTC(iState);
    end
    
    switch glasses.glassesState{iState}
        case 'None'
            idxNone   = idxTemp | idxNone;
        case 'Blue'
            idxBlue   = idxTemp | idxBlue;
        case 'Orange'
            idxOrange = idxTemp | idxOrange;
        otherwise
            error('Glasses state not recognized.')
    end
end

end

