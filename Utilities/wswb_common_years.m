function [DC,DCyrs] = wswb_common_years(D,Dyrs)

% COMMON_YEAR(D,Dyrs) determines the years common to the year vectors in
% cell input Dyrs and returns corresponding data in input cell D 
%
% INPUTS
% D		= cell of data arrays with rows that correspond to years in Dyrs
%			{d1, d2,...} where dn = [years x ...]
% Dyrs	= cell of year vectors that correspond to rows of data arrays in D
%			{dy1, dy2, ...} where dyn = [years x 1]
%
% OUTPUTS
% DC	= input data filtered by common years
% DCyrs = input Dyrs filtered by common years
%
% TC Moran UC Berkeley 2013

CYRS = sort(unique(vertcat(Dyrs{:})));		% all years
for ii = 1:length(Dyrs)
	dy = Dyrs{ii};
	CYRS = intersect(CYRS,dy);		% keep only common years
end

for ii = 1:length(Dyrs)
	chk_yrs = ismember(Dyrs{ii},CYRS);
	DC{ii} = D{ii}(chk_yrs,:);
	DCyrs{ii} = Dyrs{ii}(chk_yrs);
end

