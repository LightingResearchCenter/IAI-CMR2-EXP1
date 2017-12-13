function lightReading = adjustCS(glasses,lightReading)
%ADJUSTCS Summary of this function goes here
%   Detailed explanation goes here

[idxNone,idxBlue,idxOrange] = state2idx(glasses,lightReading);

adjCLA = lightReading.cla;
adjCLA(idxBlue)   = lightReading.cla(idxBlue) + 816.6;
adjCLA(idxOrange) = lightReading.cla(idxOrange)*0.039;

adjCS = 0.7*(1 - (1./(1 + (adjCLA/355.7).^(1.1026))));

lightReading.idxNone	= idxNone;
lightReading.idxBlue	= idxBlue;
lightReading.idxOrange	= idxOrange;
lightReading.cla     = adjCLA;
lightReading.cs      = adjCS;
end

