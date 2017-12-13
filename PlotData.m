function PlotData(t,subject)
%PLOTDATA Summary of this function goes here
%   Detailed explanation goes here

h = 

f = fit(datenum(t.tn_local),hours(t.DLMO),'poly1');
deltaFit = f(datenum(t.tn_local(end)))-f(datenum(t.tn_local(1)));

plot(f,datenum(t.tn_local),hours(t.DLMO))

t = title({['Subject: ',subject];['delta data: ',num2str(hours(t.DLMO(end)-t.DLMO(1)),'%.1f'),'  |  delta fit: ',num2str(deltaFit,'%.1f')]});
t.FontSize = 10;

ax = gca;
box off
grid on
ax.TickDir = 'out';
ax.FontSize = 8;

ax.YLim = [0,24];
ax.YTick = 0:6:24;

ax.YLabel.String = {'DLMO';'(hours)'};
ax.YLabel.FontSize = 8;

ax.XLim = [datenum(2016,12,30),datenum(2017,1,14)];
ax.XTick = datenum(2016,12,30):datenum(2017,1,14);
datetick(ax,'x','keeplimits','keepticks')
ax.XTickLabelRotation = 45;

ax.XLabel = [];



end

