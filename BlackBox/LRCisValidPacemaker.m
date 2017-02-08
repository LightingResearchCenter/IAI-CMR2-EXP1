function TF = LRCisValidPacemaker(lastPacemaker)
%LRCISVALIDPACEMAKER Check if ending values of previous pacemaker are valid
%   Input, lastPacemaker struct.
%   Output, true/false.

if ~isempty(lastPacemaker)
    % Preallocate temporary bolean array for test conditions
    temp = false(6,1);
    
    % Check that all values are not empty
    temp(1) = ~isempty(lastPacemaker.tn);
    temp(2) = ~isempty(lastPacemaker.xn);
    temp(3) = ~isempty(lastPacemaker.xcn);
    
    % Check that all values are numeric
    temp(4) = isnumeric(lastPacemaker.tn);
    temp(5) = isnumeric(lastPacemaker.xn);
    temp(6) = isnumeric(lastPacemaker.xcn);
    
    % Check that all conditions are true
    TF = all(temp);
else
    TF = false;
end

end

