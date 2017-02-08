function filePointers = LRCopen(filePaths,permission)
%LRCOPEN Summary of this function goes here
%   Detailed explanation goes here

filePointers = struct;

% Get field names
structFields = fieldnames(filePaths);
for iField = 1:numel(structFields);
    thisField = structFields{iField};
    thisPath = filePaths.(thisField);
    % Open the path
    filePointers.(thisField) = fopen(thisPath,permission);
end

end

