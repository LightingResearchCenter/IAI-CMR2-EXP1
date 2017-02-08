function LRCdelete(filePaths)
%LRCDELETE Summary of this function goes here
%   Detailed explanation goes here

% Get field names
structFields = fieldnames(filePaths);
for iField = 1:numel(structFields);
    thisField = structFields{iField};
    thisPath = filePaths.(thisField);
    % Delete the path
    delete(thisPath);
end

end

