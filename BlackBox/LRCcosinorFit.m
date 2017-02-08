function [mesor,amplitude,phi] = LRCcosinorFit(timeArraySec,valueArray)
% LRCCOSINORFIT Simplified cosinor fit
%   time is the timestamps in seconds
%   value is the set of values you're fitting

% preallocate variables
C = zeros(3, 3);
D = zeros(1, 3);

n = numel(timeArraySec);
xj    = zeros(n,1);
zj    = zeros(n,1);

omega = 2*pi/86400;
xj(:,1) = cos(omega*timeArraySec);
zj(:,1) = sin(omega*timeArraySec);

yj = zeros(size(xj));
yj(:,1) = xj(:,1);
yj(:,2) = zj(:,1);

C(1, 1) = n;
C(1, 2) = sum(xj(:,1));
C(2, 1) = sum(xj(:,1));
C(1, 3) = sum(zj(:,1));
C(3, 1) = sum(zj(:,1));

for i1 = 2:3
    for j1 = 2:3
        C(i1, j1) = sum(yj(:,(i1 - 1)).*yj(:,(j1 - 1)));
    end
end

D(1) = sum(valueArray);
for i2 = 2:3
    D(i2) = sum(yj(:,(i2 - 1)).*(valueArray));
end

D = D';

x = C\D;

mesor = x(1);
amplitude = sqrt(x(2)^2 + (x(3)^2));
phi = -atan2(x(3), x(2));


end

