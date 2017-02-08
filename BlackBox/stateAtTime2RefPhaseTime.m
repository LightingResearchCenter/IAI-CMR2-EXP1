function refPhaseTime = stateAtTime2RefPhaseTime(t,x,xc)
% STATEATTIME2REFPHASETIME Converts the state of the oscilator from a phase at a particular time
% to the time of the referece phase. The function approximates the oscillator as a harmonic oscilator
% 
%   Inputs:
%       t: time in units of seconds
%       x: state variable #1 of the oscillator
%       xc: state vaiables #2 of the oscillator
%
%   Output:
%       refPhaseTime: time in units of seconds when the oscilator is at the 
%       reference phase condition (x,xc) = (-1,0).

%% Normalize state variables
% x and xc must be between -1 and 1
if (x>1)
    x = 1;
elseif (x<-1)
    x = -1;
end
if (xc>1)
    xc = 1;
elseif (xc<-1)
    xc = -1;
end

%% Calculate phase angle and time
%
% four quadrant arccosine with range 0 to 2pi
if (x>=0 && xc>=0) % Quadrant I
    arccosine = acos(-x); % negative cosine because the model evolves clockwise
elseif (x<0 && xc>=0) % Quadrant II
    arccosine = acos(-x);
elseif (x<0 && xc<0) % Quadrant III
    arccosine = 2*pi - acos(-x);
else % Quadrant IV (x>=0 && xc<0)
    arccosine = 2*pi - acos(-x);
end
refPhaseTimeRadians = -(arccosine - t*pi/43200); % relative time in radians, negative because the model evolves clockwise
refPhaseTime = 43200/pi*refPhaseTimeRadians; % relative time in hours

% Adjust if referencing previous day
if (refPhaseTime<0)
    refPhaseTime = 86400+refPhaseTime;
end
%


%% Create return value
refPhaseTime = mod(refPhaseTime,86400); % convert values > 24 to principle values

%% alternate method
%{
arcTangent = atan2(xc,-x); % negative cosine because the model evolves clockwise
refPhaseTimeRadians2 = -(arcTangent - t*pi/12); % relative time in radians, negative because the model evolves clockwise
refPhaseTime2 = 12/pi*refPhaseTimeRadians2; % relative time in hours

% Adjust if referencing previous day
if (refPhaseTime2<0)
    refPhaseTime2 = 24+refPhaseTime2;
end
refPhaseTime2 = mod(refPhaseTime2,24); % convert values > 24 to principle values
%}

