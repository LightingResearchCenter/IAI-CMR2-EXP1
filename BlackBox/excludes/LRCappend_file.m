function LRCappend_file(fileID,dataStruct)
%LRCAPPEND_FILE Append struct values to file
%   Replace this with native function for iOS

fields = fieldnames(dataStruct);

for iValue = 1:numel(dataStruct.(fields{1}))
    nField = numel(fields);
    for iField = 1:nField
        % Get entry value
        if isempty(dataStruct.(fields{iField}))
            thisValue = 'null';
        else
            thisValue = dataStruct.(fields{iField})(iValue,:);
        end
        if iscell(thisValue)
            thisValue = thisValue{1};
        end
        
        % Define format
        thisFormat = determineFormat(thisValue);
        if iField < nField
            formatSpec = [thisFormat,','];
        else
            formatSpec = thisFormat;
        end

        % Write to file
        fprintf(fileID,formatSpec,thisValue);
    end
    % Write new line characters
    fprintf(fileID,'\r\n');
    
end

end


function objectFormat = determineFormat(object)
%DETERMINEFORMAT Return the format string for an object based on its class
%   Detailed explanation goes here

if isfloat(object)
    objectFormat = '%f';
elseif isinteger(object)
    objectFormat = '%i';
elseif ischar(object)
    objectFormat = '%s';
else
    error(['Format not specified for class of: ',class(object)]);
end

end

