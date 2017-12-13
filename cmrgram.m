classdef cmrgram < d12pack.report
    %DAYSIGRAM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Axes
        SubAxes
        Colors = struct( ...
            'lightBlue',[ 75, 179, 253]/255, ...
            'orange',   [251, 139,  36]/255, ...
            'blue',     [ 69,  81, 150]/255, ... % circadian stimulus
            'grey',     [226, 226, 226]/255, ... % excluded data
            'red',      [251,  54,  64]/255, ... % error
            'yellow',   [255, 255,  90]/255, ... % noncompliance
            'purple',   [104,  46,  75]/255, ... % in bed
            'green',    [ 57, 196, 127]/255);    % at work
    end
    
    methods
        function obj = cmrgram(varargin)
            obj@d12pack.report;
            
            if nargin == 0
                nPages = 1;
            else
                lightReading    = varargin{1};
                activityReading = varargin{2};
                reportTitle     = varargin{3};
                obj.Title = reportTitle;
                if nargin == 5
                    StartDate   = varargin{4};
                    EndDate     = varargin{5};
                else
                    StartDate   = dateshift(min([lightReading.timeLocal;activityReading.timeLocal]),'start','day');
                    EndDate     = dateshift(max([lightReading.timeLocal;activityReading.timeLocal]),'start','day');
                end
                
                Dates  = StartDate:EndDate;
                nDates = numel(Dates);
                nPages = ceil(nDates/10);
            end
            
            obj.Type = 'CMR Report';
            
            if nPages > 1
                for iPage = 1:nPages
                    if iPage > 1
                        obj(iPage,1) = cmrgram;
                    end
                    obj(iPage,1).PageNumber = [iPage,nPages];
                    obj(iPage,1).Title = reportTitle;
                end
            end
            
            if exist('lightReading','var') == 1
                iDate = 1;
                for iPage = 1:nPages
                    figure(obj(iPage,1).Figure);
                    
                    obj(iPage,1).initAxes;
                    obj(iPage,1).initLegend;
                    
                    while iDate <= iPage*10
                        if iDate <= nDates
                            % Select the axes that will be plotted to
                            iAx = mod(iDate,10);
                            if iAx == 0
                                iAx = 10;
                            end
                            
                            idxLight  = lightReading.timeLocal >= Dates(iDate) & lightReading.timeLocal < Dates(iDate) + caldays(1);
                            tLight    = lightReading.timeLocal(idxLight);
                            CS        = lightReading.cs(idxLight);
%                             adjCS     = lightReading.adjCS(idxLight); %was observation
                            idxBlue   = lightReading.idxBlue(idxLight); %was error
                            idxOrange = lightReading.idxOrange(idxLight); %was compliance
                            
                            idxActivity = activityReading.timeLocal >= Dates(iDate) & activityReading.timeLocal < Dates(iDate) + caldays(1);
                            tActivity   = activityReading.timeLocal(idxActivity);
                            AI          = activityReading.activityIndex(idxActivity);
                            idxSleep    = activityReading.idxSleep(idxActivity);
                            try
                            obj(iPage,1).plotDay(...
                                obj(iPage,1).Axes(iAx),...
                                obj(iPage,1).SubAxes(iAx),...
                                tLight,...
                                CS,...
                                idxBlue,...
                                idxOrange,...
                                tActivity,...
                                AI,...
                                idxSleep);
                            catch err
                                throw(err)
                            end
                        end
                        iDate = iDate + 1;
                    end % End of while
                end % End of for
            end % End of if
        end % End of class constructor
        
        %% initAxes creates 10 axes to plot on
        function obj = initAxes(obj)
            x = 36;
            w = obj.Body.Position(3) - x - 36;
            h = floor((obj.Body.Position(4) - 72)/10);
            
            obj.Axes = gobjects(10,1);
            obj.SubAxes = gobjects(10,1);
            for iAx = 1:10
                y = obj.Body.Position(4) - iAx*h;
                
                obj.SubAxes(iAx) = axes(obj.Body);
                obj.SubAxes(iAx).Units = 'pixels';
                obj.SubAxes(iAx).Position = [x,y,w,h];
                
                obj.SubAxes(iAx).YLimMode = 'manual';
                obj.SubAxes(iAx).YLim = [0,1];
                obj.SubAxes(iAx).XLimMode = 'manual';
                obj.SubAxes(iAx).XLim = [0,24];
                obj.SubAxes(iAx).Visible = 'off';
                
                obj.Axes(iAx) = axes(obj.Body);
                obj.Axes(iAx).Units = 'pixels';
                obj.Axes(iAx).Position = [x,y,w,h];
                
                obj.Axes(iAx).TickLength = [0,0];
                obj.Axes(iAx).YLimMode = 'manual';
                obj.Axes(iAx).YLim = [0,1];
                obj.Axes(iAx).YTick = .25:.25:.75;
                obj.Axes(iAx).YTickLabel = {'0.25','0.50','0.75'};
                obj.Axes(iAx).YGrid = 'on';
                obj.Axes(iAx).XLimMode = 'manual';
                obj.Axes(iAx).XLim = [0,24];
                obj.Axes(iAx).XTick = 0:2:24;
                obj.Axes(iAx).XTickLabel = '';
                obj.Axes(iAx).XGrid = 'on';
                obj.Axes(iAx).Color = 'none';
                
            end
            obj.Axes(10).XTickLabel = obj.Axes(10).XTick;
            hLabel = xlabel(obj.Axes(10),'Time of Day (hours)');
            
            % Box in the plots
            hBoxAxes = axes(obj.Body);
            hBoxAxes.Units = 'pixels';
            hBoxAxes.Position = [x, y, w, h*10];
            hBoxAxes.XLimMode = 'manual';
            hBoxAxes.XLim = [0,1];
            hBoxAxes.YLimMode = 'manual';
            hBoxAxes.YLim = [0,1];
            xBox = [0,1,1,0,0];
            yBox = [0,0,1,1,0];
            hBox = plot(hBoxAxes,xBox,yBox);
            hBox.Color = 'black';
            hBox.LineWidth = 0.5;
            hBoxAxes.Visible = 'off';
        end % End of initAxes
        
        %% Legend
        function initLegend(obj)
            x = 36;
            y = 0;
            w = 468;
            h = 40;
            
            hLegendAxes = axes(obj.Body); % Make a new axes for logo
            hLegendAxes.Visible = 'off'; % Set axes visibility
            hLegendAxes.Units = 'pixels';
            hLegendAxes.Position = [x,y,w,h];
            hLegendAxes.XLimMode = 'manual';
            hLegendAxes.XLim = [0,468];
            hLegendAxes.YLimMode = 'manual';
            hLegendAxes.YLim = [0,36];
            
            w = 13;
            h = 10;
            
            a = 17;
            b = 2;
            
            a2 = 17;
            b2 = -3;
            
            % Circadian Stimulus
            x = 135-65;
            y = 25;
            dim = [x,y,w,h];
            hRec = rectangle(hLegendAxes,'Position',dim,'FaceColor',obj.Colors.blue);
            hTxt = text(hLegendAxes,x+a,y+b,'Circadian Stimulus (CS)');
            hTxt.VerticalAlignment = 'baseline';
            hTxt.FontName = 'Arial';
            hTxt.FontSize = 8;
            
            % Activity Index
            x = 135-65;
            y = 11;
            hLin = line(hLegendAxes,[x,x+w],[y,y],'LineWidth',1,'Color','black');
            hTxt = text(hLegendAxes,x+a2,y+b2,'Activity Index (AI)');
            hTxt.VerticalAlignment = 'baseline';
            hTxt.FontName = 'Arial';
            hTxt.FontSize = 8;
            
            % Blue Goggles
            x = 266-65;
            y = 25;
            dim = [x,y,w,h];
            hRec = rectangle(hLegendAxes,'Position',dim,'FaceColor',obj.Colors.lightBlue);
            hTxt = text(hLegendAxes,x+a,y+b,'Blue Goggles');
            hTxt.VerticalAlignment = 'baseline';
            hTxt.FontName = 'Arial';
            hTxt.FontSize = 8;
            
            %
            x = 396;
            y = 25;
            
            
%             % Adjusted CS
%             x = 6;
%             y = 11;
%             dim = [x,y,w,h];
%             hLin = line(hLegendAxes,[x,x+w],[y,y],'LineStyle','--','LineWidth',1,'Color',obj.Colors.green);
%             hTxt = text(hLegendAxes,x+a2,y+b2,'Adjusted CS');
%             hTxt.VerticalAlignment = 'baseline';
%             hTxt.FontName = 'Arial';
%             hTxt.FontSize = 8;
            
            % Reported in Bed
            x = 396-65;
            y = 25;
            dim = [x,y,w,h];
            hRec = rectangle(hLegendAxes,'Position',dim,'FaceColor',obj.Colors.purple);
            hTxt = text(hLegendAxes,x+a,y+b,'Reported in Bed');
            hTxt.VerticalAlignment = 'baseline';
            hTxt.FontName = 'Arial';
            hTxt.FontSize = 8;
            
            % Orange Glasses
            x = 266-65;
            y = 6;
            dim = [x,y,w,h];
            hRec = rectangle(hLegendAxes,'Position',dim,'FaceColor',obj.Colors.orange);
            hTxt = text(hLegendAxes,x+a,y+b,'Orange Glasses');
            hTxt.VerticalAlignment = 'baseline';
            hTxt.FontName = 'Arial';
            hTxt.FontSize = 8;
            
        end % End of initLegend
        
    end
    
    methods
        %%
        function plotDay(obj,hAxes,hSubAxes,tLight,CS,idxBlue,idxOrange,tActivity,AI,idxSleep)
            hold(hSubAxes,'on');
            hold(hAxes,'on');
            
            HoursLight = hours(timeofday(tLight));
            HoursActivity = hours(timeofday(tActivity));
            
            if ~isempty(HoursActivity)
                % Plot sleep
                hNC = area(hSubAxes,HoursActivity,idxSleep);
                hNC.FaceColor = obj.Colors.purple;
                hNC.EdgeColor = 'none';
                hNC.DisplayName = 'Reported in Bed';
            end
            
            if ~isempty(HoursLight)
                % Plot Orange
                hNC = area(hSubAxes,HoursLight,idxOrange);
                hNC.FaceColor = obj.Colors.orange;
                hNC.EdgeColor = 'none';
                hNC.DisplayName = 'Orange Glasses';
                
                % Plot Blue
                hErr = area(hSubAxes,HoursLight,idxBlue);
                hErr.FaceColor = obj.Colors.lightBlue;
                hErr.EdgeColor = 'none';
                hErr.DisplayName = 'Blue Goggles';
                
                % Plot CS
                hCS = area(hAxes,HoursLight,CS);
                hCS.FaceColor = obj.Colors.blue;
                hCS.EdgeColor = 'none';
                hCS.DisplayName = 'Circadian Stimulus (CS)';
                
%                 % Plot adjusted CS
%                 hExc = plot(hAxes,HoursLight,adjCS,'--');
%                 hExc.Color = obj.Colors.green;
%                 hExc.LineWidth = 1;
%                 hExc.DisplayName = 'Adjusted CS';
            end
            
            if ~isempty(HoursActivity)
                % Plot AI
                hAI = plot(hAxes,HoursActivity,AI);
                hAI.Color = 'black';
                hAI.LineWidth = 1;
                hAI.DisplayName = 'Activity Index (AI)';
            end
            
            % Add Date label
            t = [tLight;tActivity];
            hDate = ylabel(hAxes,datestr(min(t),'yyyy\nmmm dd'));
            hDate.Position(1) = 24;
            hDate.Rotation = 90;
            hDate.HorizontalAlignment = 'center';
            hDate.VerticalAlignment = 'top';
            hDate.FontSize = 8;
            
            hold(hAxes,'off');
            hold(hSubAxes,'off');
        end
    end
    
end

