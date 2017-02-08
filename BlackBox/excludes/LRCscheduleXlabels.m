function LRCscheduleXlabels(axisHandle)
%LRCSCHEDULEXLABELS Summary of this function goes here
%   Detailed explanation goes here

% Get limits
xLim = get(axisHandle,'XLim');

% Create new tick values
xTicks = floor(xLim(1)):0.25:ceil(xLim(2));

% Find date changes
dateChange = mod(xTicks,1) == 0;

% Preallocate labels
xLabels = cell(size(xTicks));

% Create labels
for iLabel = 1:numel(xTicks)
    if dateChange(iLabel)
        formatSpec = 'mm/dd';
    else
        formatSpec = 'HH:MM';
    end
    xLabels{iLabel} = datestr(xTicks(iLabel),formatSpec);
end

% Set ticks and labels
set(axisHandle,'XTick',xTicks);
set(axisHandle,'XTickLabel',xLabels);

end

