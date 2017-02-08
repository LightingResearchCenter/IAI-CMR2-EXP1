function [t,x,xc] = refPhaseTime2StateAtTime(refPhaseTime,t,phaseMarker)
% REFPHASETIME2STATEATTIME Converts the state of the oscilator from the time of the referece phase
% to the state at a particular time t. The function approximates the oscillator as a harmonic oscilator,
% that is, x = -cos(2*pi*t/86400 + phi), xc = sin(2*pi*t/86400 + phi)
% 
%
%   Inputs:
%       refPhaseTime: time in units of seconds when the oscilator is at the 
%       reference phase condition (x,xc) = (-1,0).
%       t: relative time of day in units of seconds
%       phaseMarker: one of these values: 'CBTmin','DLMO','bedtime',
%                   'waketime','activityAcrophase'
%
%   Outputs:
%       t: time in units of seconds
%       x: state variable #1 of the oscillator
%       xc: state vaiables #2 of the oscillator

%% Phase marker reference switch
switch phaseMarker
    case 'CBTmin'
        %disp('CBTmin');
        phi = refPhaseTime;
    case 'DLMO'
        %disp('DLMO');
        phi = refPhaseTime + 7*3600;
    case 'bedtime'
        %disp('bedtime');
        phi = refPhaseTime + 5*3600;
    case 'waketime'
        %disp('waketime');
        phi = refPhaseTime - 3*3600;
    case 'activityAcrophase'
        %disp('activityAcrophase');
        phi = refPhaseTime - 10*3600;
    otherwise
        %disp('default');
        phi = refPhaseTime;
end

%% Calculate phase state variables
phi = phi*pi/43200; % convert from 24-hour time to radians
x = -cos(2*pi*t/86400 - phi);
xc = sin(2*pi*t/86400 - phi);

end