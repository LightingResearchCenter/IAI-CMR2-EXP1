function matlabDatenum = unix2datenum(unixTime)
%UNIX2DATENUM Converts MATLAB datenums to UNIX time
%   Rounds down to whole seconds

unixPivotDatenum = datenum(1970,01,01);
matlabDatenum = unixTime/86400 + unixPivotDatenum;

end

