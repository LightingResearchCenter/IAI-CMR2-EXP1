function lightReading = rgbc2lux(lightReading, constantsSet)
%RGBC2CLA Summary of this function goes here
%   Detailed explanation goes here

%% Extract data from table
RGBC = horzcat(lightReading.red, lightReading.green, lightReading.blue, lightReading.clear);

%% Set constants to be used
switch constantsSet
    case '2016'
        rgbcCoef = 'rgbc_2016';
        rgbCoef  = 'rgbONLY_2016';
    case '2015'
        rgbcCoef = 'rgbc_2015';
        rgbCoef  = 'rgbONLY_2015';
end

%% Calculate responses and illuminance using all channels
lux = rgbc2luxBasic(RGBC, rgbcCoef);

%% Calculate responses and illuminance using RGB ONLY
lux2 = rgbc2luxBasic(RGBC, rgbCoef);

%% Replace negative values
%  Replace negative values with RGB ONLY version
lux(lux < 0) = lux2(lux < 0);
%  Replace remaining negative values with zero
lux(lux < 0) = 0;

%% Store CLA and convert to CS
lightReading.lux = lux;

end


function lux = rgbc2luxBasic(RGBC, constantsName)
[~, ~, ~, ~, ~, V] = getConstants(constantsName);
lux = rgbc2response(RGBC, V);
end


function response = rgbc2response(RGBC, responseConstants)
response = sum(bsxfun(@times, responseConstants, RGBC), 2);
end

function [Sm, Vm, M, Vp, C, V] = getConstants(constantsName)
switch constantsName
    case 'rgbc_2016'
        %  RGB + clear
        %  Weighting constants for each response
        Sm = [-0.070462 -0.203722  0.263968  0.242391]; % Scone/macula
        Vm = [ 0.040310  0.028134 -0.112683  1.118302]; % Vlamda/macula (L+M cones)
        M  = [ 0.121249  0.376478  0.406199 -0.473712]; % Melanopsin
        Vp = [ 0.071430  0.535537  0.277295 -0.323664]; % Vprime (rods)
        V  = [ 0.025280  0.003605 -0.211515  1.181482]; % Vlambda
        %  Model coefficients: a2, a3, k, A/683
        C  = [ 0.605439  3.335625,	0.235580,	2.317553];
    case 'rgbONLY_2016'
        %  RGB ONLY
        %  Weighting constants for each response
        Sm = [ 0.000974 -0.079192  0.307072  0.0]; % Scone/macula
        Vm = [ 0.347885  0.685175  0.039656  0.0]; % Vlamda/macula (L+M cones)
        M  = [-0.016299  0.110534  0.337467  0.0]; % Melanopsin
        Vp = [-0.021986  0.358257  0.226704  0.0]; % Vprime (rods)
        V  = [ 0.385735  0.618798 -0.015556  0.0]; % Vlambda
        %  Model coefficients: a2, a3, k, A/683
        C  = [ 0.664480  3.471577  0.229064  2.312447];
    case 'rgbc_2015'
        %  RGB + clear
        %  Weighting constants for each response
        Sm = [-0.070873 -0.204847  0.265436  0.243761]; % Scone/macula
        Vm = [ 0.040024  0.028073 -0.112701  1.117983]; % Vlamda/macula (L+M cones)
        M  = [ 0.120659  0.374496  0.404917 -0.471267]; % Melanopsin
        Vp = [ 0.152405  0.679046  0.317550 -0.590977]; % Vprime (rods)
        V  = [ 0.025021  0.003694 -0.211097  1.178995]; % Vlambda
        %  Model coefficients: a2, a3, k, A/683
        C  = [ 0.583972  3.298705  0.239282 2.308392];
    case 'rgbONLY_2015'
        %  RGB ONLY
        %  Weighting constants for each response
        Sm = [ 0.000981 -0.079768  0.309320  0.0]; % Scone/macula
        Vm = [ 0.347166  0.684235  0.039616  0.0]; % Vlamda/macula (L+M cones)
        M  = [-0.016200  0.110203  0.336419  0.0]; % Melanopsin
        Vp = [-0.021933  0.356985  0.226024  0.0]; % Vprime (rods)
        V  = [ 0.385371  0.618378 -0.015533  0.0]; % Vlambda

        %  Model coefficients: a2, a3, k, A/683
        C  = [ 0.545682  3.269864  0.234354  2.309318];
end
end