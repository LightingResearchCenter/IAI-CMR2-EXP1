function LRCclose(filePointers)
%LRCCLOSE Summary of this function goes here
%   Detailed explanation goes here

% Get field names
structFields = fieldnames(filePointers);
for iField = 1:numel(structFields);
    thisField = structFields{iField};
    thisPointer = filePointers.(thisField);
    % Close the pointer
    fclose(thisPointer);
end

end

