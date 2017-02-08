function wString = LRCwarningTempFiles(filePaths)
%LRCWARNINGTEMPFILES Summary of this function goes here
%   Detailed explanation goes here

% Get names of temporary files
structFields = fieldnames(filePaths);
nFields = numel(structFields);
fileNames = cell(nFields,1);
for iField = 1:nFields
    thisField = structFields{iField};
    thisPath  = filePaths.(thisField);
    [~,name,ext] = fileparts(thisPath);
    fileNames{iField} = [name,ext];
end
% Prepare format of warning text
wBase   = 'Temporary files not deleted or moved\n\t%s ...';
wFormat = [wBase,repmat('\n\t\t%s',1,nFields)];
wString = sprintf(wFormat,tempdir,fileNames{:});

end

