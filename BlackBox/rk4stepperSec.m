function [xf,xcf] = rk4stepperSec(x0,xc0,lightDrive,ti,tf)
% RK4STEPPERSEC is an ODE solver used to determine state variable values
% of the pacemaker model at the desired point in time

% Create local variables
Bdrive = 0.56 * lightDrive;
hInterval = (tf - ti)/LRCrk4StepSize;

% Initialize loop variables
t = ti;

% Loop
for iStep = 1:LRCrk4StepSize
    % Calculate values per step
    [x0, xc0] = rk4Sec(x0,xc0,Bdrive,hInterval);
    
    % Update loop variable
    t = t + hInterval;
end

% Create return values
xf = x0;
xcf = xc0;

end


function [xout,xcout] = rk4Sec(x0,xc0,Bdrive,hInterval)
% RK4SEC calculates the derivatives of the pacemaker model at each step

% Calculate derivatives
[xprime1,xcprime1] = xprimeSec(x0,xc0,Bdrive);
x1  = hInterval/2*xprime1  + x0;
xc1 = hInterval/2*xcprime1 + xc0;

[xprime2,xcprime2] = xprimeSec(x1,xc1,Bdrive);
x2  = hInterval/2*xprime2  + x0;
xc2 = hInterval/2*xcprime2 + xc0;

[xprime3,xcprime3] = xprimeSec(x2,xc2,Bdrive);
x3  = hInterval*xprime3  + x0;
xc3 = hInterval*xcprime3 + xc0;

xdym  = 2*(xprime3  + xprime2);
xcdym = 2*(xcprime3 + xcprime2);

[xprime4,xcprime4] = xprimeSec(x3,xc3,Bdrive);

% Create output valriables
xout  = x0  + hInterval/6*(xprime1  + xprime4  + xdym);
xcout = xc0 + hInterval/6*(xcprime1 + xcprime4 + xcdym);

end


function [xprime,xcprime] = xprimeSec(x,xc,Bdrive)
% XPRIMESEC
% Model
xprime  = pi/43200*(LRCmu*(x/3 + 4/3*x^3 - 256/105*x^7) + xc + Bdrive);
xcprime = pi/43200*(LRCq*Bdrive*xc - (24/(0.99729*LRCtau))^2*x + LRCk*Bdrive*x);

end

