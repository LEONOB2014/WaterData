function day1 = firstdayofmonth(cy_month,cyear,month1)

% FIRSTDAYOFMONTH(month1) calculates the day of year of the first day of the
% input month
% NOTE: to use this for water years, input 'year = wateryear - 1', and
%		'month1 = 10'   wonky, but it works
% 
% INPUTS
% cy_month = calendar month
% cyear  = calendar year
% month1 = calendar month of first month of water year
%
% OUTPUTS
% day1   = day of calendar year of first day of input month
%
% TC Moran UC Berkeley 2012

if nargin < 2
    cyear = 2001; % arbitrary non-leap year
end
if nargin < 3
    month1 = 1; % default to calendar year
end

month0 = month1-1;

dn0 = datenum(cyear,month1,0);
dn1 = datenum(cyear,cy_month,1); 
day1 = dn1 - dn0;

if month1 > 1
   % calc days for the next calendar year (end of water year)
   cyear = cyear+1;
   dn1next = datenum(cyear,cy_month,1);
   day1next = dn1next-dn0;
   % replace negative values of day1 with values from next year
   dchk = day1 < 0;
   day1(dchk) = day1next(dchk);
end

