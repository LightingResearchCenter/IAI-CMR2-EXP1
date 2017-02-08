function panelHandle = LRCcreate_uipanel(parent,position)
%LRCCREATE_UIPANEL Summary of this function goes here
%   Detailed explanation goes here

panelHandle = uipanel(parent,'Title','Simulation Controls','Tag','ControlsPanel');

panelUnits = get(panelHandle,'Units');
set(panelHandle,'Units','pixels');
set(panelHandle,'Position',position);
set(panelHandle,'Units',panelUnits);


end

