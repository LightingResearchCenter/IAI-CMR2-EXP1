function filePaths = LRCinitTempFiles
%LRCINITTEMPFILES Summary of this function goes here
%   Detailed explanation goes here

lrPath = initLightReading;
arPath = initActivityReading;
pmPath = initPacemaker;

filePaths = struct(             ...
    'lightReading',     lrPath,	...
    'activityReading',	arPath,	...
    'pacemaker',        pmPath	...
    );

end


function filePath = initLightReading
% Create unique name for temporary file.
filePath = [tempname,'.csv'];
% Create new file for reading and writing.
% Append data to the end of the file.
filePointer = fopen(filePath,'w');
% Write header line to file.
headerStr = 'timeUTC,timeOffset,red,green,blue,cla,cs\r\n';
fprintf(filePointer,headerStr);
% Close the file and write to disk
fclose(filePointer);
end


function filePath = initActivityReading
% Create unique name for temporary file.
filePath = [tempname,'.csv'];
% Create new file for reading and writing.
% Append data to the end of the file.
filePointer = fopen(filePath,'w');
% Write header line to file.
headerStr = 'timeUTC,timeOffset,activityIndex,activityCount\r\n';
fprintf(filePointer,headerStr);
% Close the file and write to disk
fclose(filePointer);
end


function filePath = initPacemaker
% Create unique name for temporary file.
filePath = [tempname,'.csv'];
% Create new file for reading and writing.
% Append data to the end of the file.
filePointer = fopen(filePath,'w');
% Write header line to file.
headerStr = 'runTimeUTC,runTimeOffset,version,model,x0,xc0,t0,xn,xcn,tn\r\n';
fprintf(filePointer,headerStr);
% Close the file and write to disk
fclose(filePointer);
end