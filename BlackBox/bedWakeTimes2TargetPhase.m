function targetPhase = bedWakeTimes2TargetPhase(bedTime,wakeTime)

sleepDuration = mod((wakeTime - bedTime),24);
midSleep = mod((bedTime + sleepDuration/2),24);
targetPhase = (midSleep + 1.5)*3600; % seconds, 0 <= targetPhase < 86400
