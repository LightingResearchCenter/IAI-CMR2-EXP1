function DLMO = Pacemaker2Phase(t,xc,x,varargin)
%PACEMAKER2PHASE Summary of this function goes here
%   Detailed explanation goes here

if nargin == 4
    timeUnit = varargin{1};
else
    timeUnit = 'hours';
end

switch timeUnit
    case 'days'
        unitMultiplier = 1;
    case 'hours'
        unitMultiplier = 24;
    case 'minutes'
        unitMultiplier = 24*60;
    case 'seconds'
        unitMultiplier = 24*60*60;
    otherwise
        error('timeUnit must be one of the following: ''days'', ''hours'', ''minutes'', or ''seconds''.')
end

arccosine = atan2(xc,-x); %*0.5*unitMultiplier/pi - 3; % -3 is for DLMO
refPhaseTimeRadians = -(arccosine - t*2*pi); % relative time in radians, negative because the model evolves clockwise

% p = mod(p,unitMultiplier);

refPhaseTime = 0.5*unitMultiplier/pi*refPhaseTimeRadians;
DLMO = duration(mod(refPhaseTime-7,24),0,0);

end

