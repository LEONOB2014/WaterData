function [StartStop,Pwy] = wswb_seas_calc_wetseas(Pdaily,Pwy,SeasThresh,MaxMissing)

% WSWB_SEAS_CALC_WETSEAS(Pdaily,SeasThresh) calculates the first and last
% day of the wet season based on cumulative precipitation thresholds
%
% INPUTS
% Pdaily	= array of daily precip [Nyears x 366]
% Pwy		= water year that corresponds to each row of Pdaily
% SeasThresh= thresholds to define start/end of wet season as fraction of
%			cumulative precipitation [start, end]
% MaxMissing= max allowable number of missing days of P data for any year
%
% StartStop = start and end days for wet season [day of water year]
% Pwy		= list of water years for
%
% TC Moran UC Berkeley 2013

%% ** ISSUE: LENGTH OF WATER YEAR IS NOT CONSISTENT ** 

%% INTITIALIZE
if nargin < 3
	SeasThresh(1) = 0.05;	% default: wet seas starts when 5% of total yearly P
	SeasThresh(2) = 0.95;	% default: wet seas ends when 95% of total yearly P
end
if nargin < 4
	MaxMissing = 25;		% default: max number of missing days of P data
end

%% FILTER YEARS WITH TOO MANY MISSING DAYS OF P DATA
pchk = sum(isnan(Pdaily),2)<MaxMissing;
Pdaily = Pdaily(pchk,:);
Pwy = Pwy(pchk);

%% CALCULATE SEASON START STOP DAYS
for nn = 1:size(Pdaily,1)
	pyr = Pdaily(nn,:);
	pyr(isnan(pyr)) = 0;	% get rid of nans, assume 0 for now
	ptot = nansum(pyr);
	pmin = ptot*SeasThresh(1);
	pmax = ptot*SeasThresh(2);
	pcum = cumsum(pyr);
	tstart(nn,1) = find(pcum>=pmin,1)-1;	% start wet season day before threshold day
	tstop(nn,1)  = find(pcum>=pmax,1)+1;	% stop wet season day after threshold day
end

StartStop = [tstart, tstop];
