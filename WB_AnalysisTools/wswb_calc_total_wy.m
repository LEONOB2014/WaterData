function [Dtot,wys] = wswb_calc_total_wy(Dcy,cys,dowy1,MinDays)

% WSWB_CALC_WB_WY(Dcy,cys,dowy1) calculates annual water balance totals for
% the water year defined by 'dowy1' as the first day of the water year.
%
% INPUTS
% Dcy	= daily data, calendar year array [Nyears x docy]
% cys	= data calendar years [Nyears x 1]
%
% OUTPUTS
% Dtot	= total for water year
% wys	= water years
%
% TC Moran UC Berkeley 2013

%% INITIALIZE
if nargin < 4
	MinDays = WB_PARAMS('MinDaysRwb');
end

%% CONVERT DAILY ARRAYS TO WATER YEARS
[Dwy,wys] = cy2wy_daily(Dcy, cys, dowy1);

%% FILTER WATER YEARS WITH TOO LITTLE DATA
chkN	= sum(~isnan(Dwy),2)>=MinDays; 
Dwy		= Dwy(chkN,:);
wys		= wys(chkN);

%% SUM VALID WATER YEARS
Dtot = nansum(Dwy,2);