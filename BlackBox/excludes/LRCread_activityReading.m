function activityReading = LRCread_activityReading(fileID)
%LRCREAD_ACTIVITYREADING Replace with native C functions
%   For use with MATLAB only. DO NOT use for codegen.

formatSpec = '%f %f %f %f';
C = textscan(fileID,formatSpec,...
    'Delimiter',',','HeaderLines',1,'TreatAsEmpty','null');
frewind(fileID);

activityReading = struct(	...
    'timeUTC',      C(1),	...
    'timeOffset',	C(2),	...
    'activityIndex',C(3),	...
    'activityCount',C(4)	...
    );

end
