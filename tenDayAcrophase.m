function [acrophaseTime, acroDLMO, varargout] = tenDayAcrophase(activityReading, stopTime, varargin)
%MOVINGACROPHASE Summary of this function goes here
%   Detailed explanation goes here


windowDuration = duration(10*24,0,0);

startTime  = stopTime - windowDuration;
stopTime.TimeZone = 'UTC';
startTime.TimeZone = 'UTC';

idx = activityReading.timeUTC >= posixtime(startTime) & activityReading.timeUTC <= posixtime(stopTime);

activityReading = activityReading(idx,:);
activityTimeLocal = LRCutc2local(activityReading.timeUTC,activityReading.timeOffset);
% Fit activity data with cosine function
[mesor,amplitude,acrophaseAngle] = LRCcosinorFit(activityTimeLocal,activityReading.activityIndex);
acrophaseTime = LRCacrophaseAngle2Time(acrophaseAngle);
[tLocalRel,x,xc] = refPhaseTime2StateAtTime(acrophaseTime,mod(activityTimeLocal(1),86400),'activityAcrophase');
% convert back to absolute UTC Unix time
tLocal = tLocalRel + 86400*floor(activityTimeLocal(1)/86400);
t = LRClocal2utc(tLocal,activityReading.timeOffset(1));

[~, acroDLMO] = state2dlmo(t, x, xc);

acrophaseTime = duration(0,0,acrophaseTime);

if nargin > 2
    ax = varargin{1};
    dt = datetime(activityReading.timeUTC, 'ConvertFrom', 'posixtime', 'TimeZone', 'UTC');
    dt.TimeZone = 'local';
    t2 = hour(dt) + 10*round(minute(dt)/10)/60;
    t3 = unique(t2);
    a = zeros(size(t3));
    for it = 1:numel(t3)
        a(it) = mean(activityReading.activityIndex(t2 == t3(it)));
    end
    
    y = mesor + amplitude.*cos(2*pi.*t3./24 + acrophaseAngle);
    
    plot(ax, t3, a, 'o', 'DisplayName', 'Mean Activity Index', 'Color', [0.3 0.3 0.3])
    hold(ax, 'on')
    plot(ax, t3, y, ':', 'DisplayName', 'Cosinor Fit', 'Color', [0.3 0.3 0.3])
    plot(ax, hours([acrophaseTime, acrophaseTime]), [0, max(y)], '-', 'DisplayName', 'Acrophase', 'Color', [0.3 0.3 0.3])
    text(hours(acrophaseTime) + 0.1, max(y)/2, char(acrophaseTime))
    legend(ax, 'Location', 'southoutside', 'Orientation', 'horizontal')
    ylabel('Activity Index')
    xlabel('Local Time of Day (hours)')
    ax.YLim = [0 max(vertcat(a,y))];
    ax.XLim = [0 24];
    ax.Box = 'off';
    ax.XTick = 0:2:24;
    ax.TickDir = 'out';
    ax.XGrid = 'on';
    hold(ax, 'off')
end

if nargout > 2
    varargout{1} = mesor;
    varargout{2} = amplitude;
end

end

function [dt, dlmo] = state2dlmo(t, x, xc)

% Convert UNIX time to local datetime
dt = datetime(t, 'ConvertFrom', 'posixtime', 'TimeZone', 'America/New_York');

% Convert datetime to local UNIX time
dt2 = dt; % Copy dt
dt2.TimeZone = ''; % Strip time zone
t2 = posixtime(dt2); % Convert from datetime to UNIX time

% Convert state to DLMO
state2cbtmin = @(tLocal,x,xc)altState2Ref(tLocal,x,xc); % Anonymous function
cbtMin = arrayfun(state2cbtmin, t2, x, xc); % Convert state to CBTmin
dlmo   = duration(mod(cbtMin-7, 24), 0, 0); % Convert CBTmin to DLMO

% Fix date rollover
dlmo(dlmo < duration(12,0,0)) = duration(24,0,0) + dlmo(dlmo < duration(12,0,0));

end

function refPhaseTime = altState2Ref(t,x,xc)

% Convert t from seconds to hours
t = t/3600;
% Remove date component of t
t = mod(t, 24);

arcTangent = atan2(xc,-x); % negative cosine because the model evolves clockwise

omega = pi/12; % approximate angular velocity

refPhaseTimeRadians2 = -(arcTangent - t*omega); % relative time in radians, negative because the model evolves clockwise
refPhaseTime = 12/pi*refPhaseTimeRadians2; % relative time in hours

% Adjust if referencing previous day
if (refPhaseTime<0)
    refPhaseTime = 24+refPhaseTime;
end
refPhaseTime = mod(refPhaseTime,24); % convert values > 24 to principle values
end