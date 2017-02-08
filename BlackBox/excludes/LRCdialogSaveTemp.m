function [choice,varargout] = LRCdialogSaveTemp
%LRCDIALOGSAVETEMP Summary of this function goes here
%   Detailed explanation goes here

question = 'Would you like to save the test files?';
options = {'Yes','No'};
choice = questdlg(question,'Save test files?',options{1},options{2},options{1});

if nargout == 2
    varargout{1} = options;
end

end

