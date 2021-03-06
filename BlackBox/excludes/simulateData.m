function [lightReading,activityReading] = simulateData(startTimeUTC,timeOffset,simDuration,samplingInterval)


% Separate time for activity and light readings to simulate data comming
% from different devices. A random offset of up to 30 seconds is added to
% each time array.
timeUTC_CS = (startTimeUTC+round(30*rand(1,1)):samplingInterval:startTimeUTC+simDuration)'; 
phase = pi/8*rand(1,1);
CS = 0.5*rand(size(timeUTC_CS)).*sin(pi*timeUTC_CS/(24*3600)+phase).^6;
b = fir1(20,0.2);
CS = filtfilt(b,1,CS);

timeUTC_Activity = (startTimeUTC+round(30*rand(1,1)):samplingInterval:startTimeUTC+simDuration)';
phase = phase - pi/2*rand(1,1);
AI = 0.5*rand(size(timeUTC_Activity)).*sin(pi*timeUTC_Activity/(24*3600)+phase).^6;
AI(AI>0.05) = 1;
AI(AI<=0.05) = 0;
AI = rand(size(AI)).*AI;
AI = filtfilt(b,1,AI);

matSize = size(timeUTC_CS);
lightReading = struct(                          ...
    'timeUTC',      timeUTC_CS,                 ...
    'timeOffset',   repmat(timeOffset,matSize), ...
    'red',          zeros(matSize),             ...
    'green',        zeros(matSize),             ...
    'blue',         zeros(matSize),             ...
    'cla',          zeros(matSize),             ...
    'cs',           CS                          ...
    );

matSize = size(timeUTC_Activity);
activityReading = struct(                           ...
    'timeUTC',          timeUTC_Activity,           ...
    'timeOffset',       repmat(timeOffset,matSize),	...
    'activityIndex',    AI,                         ...
    'activityCount',    zeros(matSize)              ...
    );
end