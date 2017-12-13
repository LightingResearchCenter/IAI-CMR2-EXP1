function FilteredAcrophaseComparison

% Reset
fclose('all');
close all
clear
clc

% Dependecies
addpath('BlackBox');

% Load data
f303 = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\CMR2-Exp1-Data\303-97BC\97BC_2017_01_13_08_12_00_archive\activityReading.csv';
t303 = readtable(f303);

% Convert time
timeUTC = datetime(t303.timeUTC,'ConvertFrom','posixtime','TimeZone','UTC');
timeLocal = timeUTC;
timeLocal.TimeZone = 'local';

% Crop to last 10 days of baseline
idx = timeLocal >= datetime(2016,12,30,17,0,0,'TimeZone','local')-10 & timeLocal <= datetime(2016,12,30,17,0,0,'TimeZone','local');
timeUTC = timeUTC(idx);
timeLocal = timeLocal(idx);
activityIndex = t303.activityIndex(idx);

% Filter data
% Design filter
windowSize = 10;
b = (1/windowSize)*ones(1,windowSize);
a = 1;
% Apply filter to data
activityIndex10 = filtfilt(b,a,activityIndex);

% Apply filter to data
activityIndexLn = log(activityIndex);

% Apply filter to data
activityIndexTh = activityIndex>=0.5;

% Compute acrophase
[mesor,   amplitude,   phi]   = cosinorfit(datenum(timeLocal), activityIndex,   1, 1);
[mesor10, amplitude10, phi10] = cosinorfit(datenum(timeLocal), activityIndex10, 1, 1);
[mesorLn, amplitudeLn, phiLn] = cosinorfit(datenum(timeLocal), activityIndexLn, 1, 1);
[mesorTh, amplitudeTh, phiTh] = cosinorfit(datenum(timeLocal), activityIndexTh, 1, 1);

% Plot the data
figure

subplot(4,1,1)
y = mesor + amplitude*cos(2*pi*datenum(timeLocal) + phi);
plot(timeLocal,[activityIndex,y])
title(sprintf('Filter: none, Acrophase: %.3f (hours)',phi*12/pi))
legend('Activity Index','Cosinor Fit')

subplot(4,1,2)
y10 = mesor10 + amplitude10*cos(2*pi*datenum(timeLocal) + phi10);
plot(timeLocal,[activityIndex10,y10])
title(sprintf('Filter: 10-sample moving average, Acrophase: %.3f (hours)',phi10*12/pi))
legend('Activity Index','Cosinor Fit')

subplot(4,1,3)
yLn = mesorLn + amplitudeLn*cos(2*pi*datenum(timeLocal) + phiLn);
plot(timeLocal,[activityIndexLn,yLn])
title(sprintf('Filter: natural log, Acrophase: %.3f (hours)',phiLn*12/pi))
legend('Activity Index','Cosinor Fit')

subplot(4,1,4)
yTh = mesorTh + amplitudeTh*cos(2*pi*datenum(timeLocal) + phiTh);
plot(timeLocal,[activityIndexTh,yTh])
title(sprintf('Filter: threshold (0.5), Acrophase: %.3f (hours)',phiTh*12/pi))
set(gca,'YLim',[-0.1,1.1])
legend('Activity Index','Cosinor Fit')

end

function [mesor,amplitude,phi] = cosinorfit(timeArray,valueArray,Freq,fitOrder)
% COSINORFIT
%   time is the timestamps in days
%   value is the set of values you're fitting
%   Freq is the frequency in 1/days
%	fitOrder is the order of the fit

% preallocate variables
amplitude = zeros(1,fitOrder);
phi       = zeros(1,fitOrder);

C = zeros(2*fitOrder + 1, 2*fitOrder + 1);
D = zeros(1, 2*fitOrder + 1);

n = numel(timeArray);
omega = zeros(1,fitOrder);
xj    = zeros(n,fitOrder);
zj    = zeros(n,fitOrder);
for i1 = 1:fitOrder
    omega(i1) = 2*i1*pi*Freq;
    xj(:,i1) = cos(omega(i1)*timeArray);
    zj(:,i1) = sin(omega(i1)*timeArray);
end

yj = zeros(size(xj));
for i2 = 2:2:2*fitOrder
    yj(:,i2 - 1) = xj(:,i2/2);
    yj(:,i2) = zj(:,i2/2);
end

num = length(timeArray);

C(1, 1) = num;
for i3 = 2:2:2*fitOrder
    C(1, i3) = sum(xj(:,i3/2));
    C(i3, 1) = sum(xj(:,i3/2));
    C(1, i3 + 1) = sum(zj(:,i3/2));
    C(i3 + 1, 1) = sum(zj(:,i3/2));
end

for i4 = 2:2*fitOrder + 1
    for j4 = 2:2*fitOrder + 1
        C(i4, j4) = sum(yj(:,(i4 - 1)).*yj(:,(j4 - 1)));
    end
end

D(1) = sum(valueArray);
for i5 = 2:2*fitOrder + 1
    D(i5) = sum(yj(:,(i5 - 1)).*(valueArray));
end

D = D';

x = C\D;

mesor = x(1);

for i6 = 1:fitOrder
    amplitude(i6) = sqrt(x(2*i6)^2 + (x(2*i6 + 1)^2));
    phi(i6) = -atan2(x(2*i6 + 1), x(2*i6));
end


end