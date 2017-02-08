function buttonHandle = createStopButton(parentHandle)
%CREATESTOPBUTTON Summary of this function goes here
%   Detailed explanation goes here


parentUnits = get(parentHandle,'Units');
set(parentHandle,'Units','pixels');
parentPosition = get(parentHandle,'Position');
parentWidth = parentPosition(3);
parentHeight = parentPosition(4);

margin = 5;
buttonWidth = parentWidth/2 - 3*margin;
buttonHeight = parentHeight/4 - 5*margin;
% buttonX = margin;
% buttonY = margin;
buttonX = (parentWidth - buttonWidth)/2;
buttonY = (parentHeight - buttonHeight)/2;
buttonPosition = [buttonX,buttonY,buttonWidth,buttonHeight];

buttonHandle = uicontrol(parentHandle);
set(buttonHandle,'Style','pushbutton');
set(buttonHandle,'String','STOP');
set(buttonHandle,'Position',buttonPosition);
set(buttonHandle,'Callback','runflag=false;');
set(buttonHandle,'BackgroundColor','red');
set(buttonHandle,'FontSize',16);
set(buttonHandle,'FontWeight','bold');

% Return units to starting value
set(parentHandle,'Units',parentUnits);
end

