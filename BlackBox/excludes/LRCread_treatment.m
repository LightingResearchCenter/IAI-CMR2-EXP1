function treatment = LRCread_treatment(fileID)
%LRCREAD_TREATMENT Replace with native C functions
%   For use with MATLAB only. DO NOT use for codegen.
%   Does NOT support commas within strings.

formatSpec = '%f %f %s %s %*[^\n]';
C = {};
while ~feof(fileID)
    D = textscan(fileID,formatSpec,inf,...
        'Delimiter',',','HeaderLines',1,'TreatAsEmpty','null');
    C = [C;D];
end

if size(C,1) > 1
    % Find empty cells
    idxEmpty = cellfun(@isempty,C);
    % Find empty rows
    rowEmpty = all(idxEmpty,2);
    % Delete empty rows
    C(rowEmpty,:) = [];
end

treatment = struct(         ...
    'startTime',	C(1),	...
    'durationMins', C(2),	...
    'subjectId',	C(3),	...
    'hubId',        C(4)	...
    );

end

