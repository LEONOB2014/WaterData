function day1 = firstdayofmonth(month,year,month1)

% MONTH1_2_DAY1(month1) calculates the day of year of the first day of the
% input month
% 
% INPUTS
% month = calendar month
% year  = calendar year
% month1 = calendar month of first month of water year
%
% OUTPUTS
% day1   = day of calendar year of first day of input month
%
% TC Moran UC Berkeley 2012

if nargin < 2
    year = 2001; % arbitrary non-leap year
end
if nargin < 3
    month1 = 1; % default to calendar year
end

month0 = month1-1;

dn0 = datenum(year,month1,0);
dn1 = datenum(year,month,1); 
day1 = dn1 - dn0;

if month1 > 1
   % calc days for the next calendar year (end of water year)
   year = year+1;
   dn1next = datenum(year,month,1);
   day1next = dn1next-dn0;
   % replace negative values of day1 with values from next year
   dchk = day1 < 0;
   day1(dchk) = day1next(dchk);
end

