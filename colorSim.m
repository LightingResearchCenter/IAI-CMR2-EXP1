%% Reset matlab
close all
clear
clc


%% Initialize figure
h = figure;
h.Units = 'normalized';
h.Position = [0 0 1 1];

%%
varRed = table;
varRed.red   = 10.^(0:0.01:5)';
varRed.green = 500*ones(size(varRed.red));
varRed.blue  = 500*ones(size(varRed.red));
varRed.clear = zeros(size(varRed.red));
chromaticity = rgb2chrom(varRed.red,varRed.green,varRed.blue);
[u,v] = cie31to60(chromaticity(:,1),chromaticity(:,2));
varRed.cct = chrom2cct(u,v);

varRed2016 = rgbc2cla(varRed, '2016');
varRed2015 = rgbc2cla(varRed, '2015');

subplot(1,3,1)
yyaxis left
set(gca, 'YColor', 'red')
loglog(varRed.red, [varRed2016.cla, varRed2015.cla], 'Color', 'red')
set(gca, 'YLim', [10^0 10^5])
ylabel('CLA Estimate')
xlabel('Red "lux"')

yyaxis right
set(gca, 'YColor', 'black')
plot(varRed.red, varRed.cct, 'Color', 'black')
set(gca, 'YLim', [1500 5000])
set(gca, 'XLim', [10^0 10^5])
ylabel('CCT Estimate')

legend('2016', '2015', 'CCT')

%%
varGreen = table;
varGreen.green = 10.^(0:0.01:5)';
varGreen.red   = 500*ones(size(varGreen.green));
varGreen.blue  = 500*ones(size(varGreen.green));
varGreen.clear = zeros(size(varGreen.green));
chromaticity   = rgb2chrom(varGreen.red,varGreen.green,varGreen.blue);
[u,v] = cie31to60(chromaticity(:,1),chromaticity(:,2));
varGreen.cct = chrom2cct(u,v);

varGreen2016 = rgbc2cla(varGreen, '2016');
varGreen2015 = rgbc2cla(varGreen, '2015');

subplot(1,3,2)
yyaxis left
set(gca, 'YColor', 'green')
loglog(varGreen.green, [varGreen2016.cla, varGreen2015.cla], 'Color', 'green')
set(gca, 'YLim', [10^0 10^5])
ylabel('CLA Estimate')
xlabel('Green "lux"')

yyaxis right
set(gca, 'YColor', 'black')
plot(varGreen.green, varGreen.cct, 'Color', 'black')
set(gca, 'YLim', [1500 5000])
set(gca, 'XLim', [10^0 10^5])
ylabel('CCT Estimate')

legend('2016', '2015', 'CCT')

%%
varBlue = table;
varBlue.blue  = 10.^(0:0.01:5)';
varBlue.red   = 500*ones(size(varBlue.blue));
varBlue.green = 500*ones(size(varBlue.blue));
varBlue.clear = zeros(size(varBlue.blue));
chromaticity  = rgb2chrom(varBlue.red,varBlue.green,varBlue.blue);
[u,v] = cie31to60(chromaticity(:,1),chromaticity(:,2));
varBlue.cct = chrom2cct(u,v);

varBlue2016 = rgbc2cla(varBlue, '2016');
varBlue2015 = rgbc2cla(varBlue, '2015');

subplot(1,3,3)
yyaxis left
set(gca, 'YColor', 'blue')
loglog(varBlue.blue, [varBlue2016.cla, varBlue2015.cla], 'Color', 'blue')
set(gca, 'YLim', [10^0 10^5])
ylabel('CLA Estimate')
xlabel('Blue "lux"')

yyaxis right
set(gca, 'YColor', 'black')
plot(varBlue.blue, varBlue.cct, 'Color', 'black')
set(gca, 'YLim', [1500 5000])
set(gca, 'XLim', [10^0 10^5])
ylabel('CCT Estimate')

legend('2016', '2015', 'CCT')