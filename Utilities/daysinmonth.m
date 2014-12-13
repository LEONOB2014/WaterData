function ndays_mo = daysinmonth(month,cyear)

% NUMDAYSINMONTH(month,cyear,month1) calculates the number of days in
% the month
%
% INPUT
% month     = vector of months
% cyear     = vector of calendar years
% month1    = first month of output year, e.g. 10 for Oct-Sep water year
%
% OUTPUT
% ndays     = array of number of days in each month of [cyears x months]
%
% TC Moran UC Berkeley 2012

%% INITIALIZE
if nargin < 2, cyear = 2001; end % arbitrary non-leap year default
% make sure inputs are the right shape
m(1,:) = month;
month = m;
y(:,1) = cyear;
cyear = y;

%% MAKE YEAR AND MONTH ARRAYS
nyrs = length(cyear);
nmos = length(month);

MOS = repmat(month,nyrs,1);
CYS = repmat(cyear,1,nmos);

MOS1 = MOS + 1; % months + 1

day1_mo = firstdayofmonth(MOS,CYS);
day1_mo_next = firstdayofmonth(MOS1,CYS);

ndays_mo = day1_mo_next - day1_mo;

