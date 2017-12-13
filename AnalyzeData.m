function t = AnalyzeData(t)
%ANALYZEDATA Summary of this function goes here
%   Detailed explanation goes here

% %% Convert pacemaker coordinates to phase angle time
% t.ref = (-atan2(t.xcn,-t.xn)+mod(datenum(t.tn),1)*2*pi)*12/pi;
% t.ref(t.ref<0) = t.ref(t.ref<0) + 24;
% t.delta = t.ref-t.ref(1);
% % t.delta(t.delta>12) = -24+t.delta(t.delta>12);
% % t.delta(t.delta<-13) = 24+t.delta(t.delta<-13);
% 
% %%
% t.reltime = days(t.tn - t.t0(1));


t.tn_utc = datetime(t.tn,'ConvertFrom','posixtime','TimeZone','UTC');
t.tn_local = t.tn_utc;
t.tn_local.TimeZone = 'local';
t.DLMO = Pacemaker2Phase(datenum(t.tn_local),t.xcn,t.xn);
end

