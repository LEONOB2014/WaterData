function [d_mo_wy,d_wys] = cy2wy_monthly(d_mo_cy, d_cys, wy_month1)

% CY2WY_MONTHLY(d_mo_cy, d_cys) converts data from [CalendarYear x Month]
% format to [WaterYear x Month] and converts the input calendar years to
% water years
%
% INPUTS
% d_mo_cy   = [CalendarYear x Month], [#CalYears x 12] data array
% d_cys     = vector of calendar years that correspond to rows of d_mo_cy
% wy_month1 = number that specifies calendar month of first month of water
%             year, e.g. 10 -> Oct - Sep water year
%
% OUTPUTS
% d_mo_wy   = [WaterYear x Month], [#WYears x 12] data array
% d_wys     = vector of water years that correspond to rows of d_mo_wy
%
% TC Moran UC Berkeley 2012

%% INITIALIZE
if nargin < 3, wy_month1 = 10; end % default to Oct-Sep water year

dcy = d_mo_cy;
ncy = size(dcy,1);

if ~iscell(dcy) % preallocate dwy, one fewer year than cy data
	dwy = nan(ncy-1,12);    	
else	
	dwy = cell(ncy-1,12);
end

dwy(:,1:(12-wy_month1+1)) = dcy(1:end-1,wy_month1:end);
dwy(:,(12-wy_month1+2):end) = dcy(2:end,1:wy_month1-1);

d_mo_wy = dwy;
d_wys = d_cys(2:end);
