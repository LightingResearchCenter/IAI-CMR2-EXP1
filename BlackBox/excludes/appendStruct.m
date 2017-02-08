function S1 = appendStruct(S1,S2)
%APPENDSTRUCT Append contents of struct to another for the same fieldnames
%   Append S2 contents to S1. Contents are assumed to be vertical arrays of
%   the same type.

fieldNameArray = fieldnames(S2);

for iField = 1:numel(fieldNameArray)
    thisField = fieldNameArray{fieldNameArray};
    if isfield(S1,thisField)
        S1.(thisField) = [S1.(thisField);S2.(thisField)];
    end
end


end

