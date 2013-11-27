function [Dcy,cys] = wy2cy(Dwy, wys, date_type, wy_date1)

% WY2CY(Dwy, wys, day_month, wy_date1) converts data from [WaterYear x Date]
% format to [CalendarYear x Date] and converts the input calendar years to
% water years
%
% INPUTS
% Dwy		= [WaterYear x Date], [#WaterYears x 12] (month) or [#CalYears x 366] (day) data array
% wys		= vector of water years that correspond to rows of Dwy
% date_type = specify daily or monthly data ['month' or 'day']
% wy_date1	= number that specifies calendar date of beginning of water
%             year, e.g. Oct -> Sep water year month1 = 10, day1 = 274 (non-leap)
%
% OUTPUTS
% Dcy		= [CalendarYear x Date], [#CalYears x (12 or 366)] data array
% cys		= vector of calendar years that correspond to rows of d_mo_wy
%
% TC Moran UC Berkeley 2013

%% INITIALIZE
if nargin < 3, date_type = 'month'; end % default to monthly data
if nargin < 4							% default to Oct-Sep water year
	if strcmp(date_type,'month'), wy_date1 = 10;
	else wy_date1 = 274;	% Oct 1, non-leap
	end
end

if strcmp(date_type,'month')
	ndate = 12;
elseif strcmp(date_type,'day')
	ndate = 366;
else
	display('date_type must be either "month" or "day"')
	return
end
cy1 = ndate-wy_date1+2;	% first date of CY relative to WY

%% PREALLOCATE DWY
nwy = size(Dwy,1);

if ~iscell(Dwy) % preallocate Dcy, same size as Dwy for now
	Dcy = nan(nwy,ndate);
else
	Dcy = cell(nwy,ndate);
end

%% CYCLE THROUGH YEARS
nwy = length(wys);

for yy = 1:nwy
	cys(yy,1) = wys(yy);
	Dcy(yy,1:wy_date1-1) = Dwy(yy,cy1:ndate);
	wynext = cys(yy)+1;
	idx_wynext = find(wys==wynext);
	if isempty(idx_wynext)
		continue
	end;
	Dcy(yy,wy_date1:ndate) = Dwy(idx_wynext,1:cy1-1);
end
% Pre-pend end of first water year
dcy1 = nan(1,ndate);
dcy1(wy_date1:ndate) = Dwy(1,1:cy1-1);
cy1 = wys(1)-1;
Dcy = [dcy1;Dcy];
cys = [cy1;cys];
