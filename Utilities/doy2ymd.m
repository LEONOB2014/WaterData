function ymd = doy2ymd(doy,y)

% DOY2YMD(DOY,Y) converts day of year 'doy' to [YYYY,MM,DD] vector
%
% INPUTS
% doy   = day of year [1:366]
% y     = year
%
% OUTPUTS
% ymd   = [year, month, day] vector [yyyy,mm,dd]
%
% TC Moran UC Berkeley 2012

%% CHECK WHETHER LEAP YEAR
d0 = datenum(y,0,0);
d = d0+doy;
[Y,M,D] = datevec(d);

% Return empty vector if wrapped around to next year (e.g. leap or input
% error)
if Y ~= y, ymd = []; return, end

ymd = [Y,M,D];