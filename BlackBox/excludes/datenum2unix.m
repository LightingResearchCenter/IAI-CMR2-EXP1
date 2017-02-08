function unixTime = datenum2unix(matlabDatenum)
%DATENUM2UNIX Converts MATLAB datenums to UNIX time
%   Rounds down to whole seconds

unixPivotDatenum = datenum(1970,01,01);
unixTime = floor(86400*(matlabDatenum - unixPivotDatenum));

end

