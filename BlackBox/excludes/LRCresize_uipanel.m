function LRCresize_uipanel(hObject,eventdata)
%LRCRESIZE_UIPANEL Summary of this function goes here
%   Detailed explanation goes here

figHandle = gcbo;
axisHandle = findobj(figHandle,'Tag','ControlsAxis');
panelHandle = findobj(axisHandle,'Tag','ControlsPanel');      

% change panel units to pixels and adjust position
axisUnits = get(axisHandle,'Units');
panelUnits = get(panelHandle,'Units');

set(axisHandle,'Units','pixels');
set(panelHandle,'Units','pixels');

axisPosition = get(axisHandle,'Position'); 
set(panelHandle,'Position',axisPosition);

% restore original units
set(axisHandle,'Units',axisUnits);
set(panelHandle,'Units',panelUnits);
      
end

