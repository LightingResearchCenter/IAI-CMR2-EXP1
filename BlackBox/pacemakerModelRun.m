function [tn,xn,xcn] = pacemakerModelRun(t0,x0,xc0,increment,lightArray)
%   PACEMAKERMODELRUN runs the LRC's version of the circadian pacemaker 
%   model (based on Kronauer's 1999 paper) using the given light data.
%
%   Input:
%       t0: The initial relative time of the data in seconds (0.0<=t0<86400)
%       x0: Pacemaker state variable #1 (x-axis) initial value
%       xc0: Pacemaker state variable #2 (y-axis) initial value
%       increment: The time between sequencial lightArray data points in
%       seconds
%       lightArray: an array of CS values
%
%   Ouput:
%       tf: The final relative time of the data in seconds (0.0<=tf<86400)
%       xf: Pacemaker state variable #1 (x-axix) final value
%       xcf: Pacemaker state variable #2 (y-axix) final value
%

% Number of readings
nReadings = numel(lightArray);

% Initial loop values
t1 = t0:increment:increment*(nReadings-2)+t0;
t2 = t1 + increment;
x = x0;
xc = xc0;

% Loop
for iReading = 1:nReadings-1
    % Set light drive
    lightDrive = (lightArray(iReading) + lightArray(iReading + 1))/2;
    
    [x,xc] = rk4stepperSec(x,xc,lightDrive,t1(iReading),t2(iReading));
end

tn = t2(end);
xn = x;
xcn = xc;

end





