function [timeActualScene,actualScene] = LRCscene2actual(timeScene,scene,bedTime,riseTime,workStart,workEnd)
%LRCSCENE2ACTUAL Summary of this function goes here
%   Detailed explanation goes here

timeActualScene = timeScene;
actualScene = scene;

hour = mod(timeScene,1)*24;

idxLow = scene == 0;
actualScene(idxLow) = 0.25;

if bedTime > riseTime
    idxBed = hour >= bedTime | hour < riseTime;
else
    idxBed = hour >= bedTime & hour < riseTime;
end

if workStart > workEnd
    idxWork = hour >= workStart | hour < workEnd;
else
    idxWork = hour >= workStart & hour < workEnd;
end

idxOff = idxBed | idxWork;
actualScene(idxOff) = 0;

end

