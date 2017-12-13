function calibrationArray = readCalibration(filePath)
%READCALIBRATION Summary of this function goes here
%   Detailed explanation goes here

t = readtable(filePath);
[~, idx] = ismember('mSmart*Light',t.deviceType);
calibrationArray = str2double(split(t.calibrationArray{idx},'::'));

end

