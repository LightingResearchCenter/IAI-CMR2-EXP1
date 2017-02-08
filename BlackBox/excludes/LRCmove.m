function LRCmove(saveDir,filePaths)
%LRCMOVE Move files to new directory and rename based on fieldname
%   Detailed explanation goes here

% Get field names
structFields = fieldnames(filePaths);
for iField = 1:numel(structFields);
    thisField = structFields{iField};
    thisPath = filePaths.(thisField);
    % Get the file extension
    [~,~,thisExt] = fileparts(thisPath);
    % Create new path string
    newPath = fullfile(saveDir,[thisField,thisExt]);
    % Move and rename file
    movefile(thisPath,newPath,'f');
end

end

