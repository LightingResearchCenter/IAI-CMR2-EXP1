function readingIncrement = LRCgetReadingInc(timeUTC)
%LRCGETREADINGINC Summary of this function goes here
%   Detailed explanation goes here

readingIncrement = (timeUTC(end) - timeUTC(1))/(numel(timeUTC)-1);

% Alternate method
% readingIncrement = mode(round(diff(timeUTC)));

end

