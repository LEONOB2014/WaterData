function st = wswb_nested_scenes(st_master,ID,ids,data_type)

% WSWB_NESTED_SCENES(st_master,ID,ids,var_type) determines intervals and
% IDs for calculations involving nested watersheds 'ids' that are nested in 
% watershed 'ID'. Nested watersheds are filtered for Area >= MinAreaFraction
% and overlapping interval T >= MinYears.
%
% Two types of 'scenes' are calculated:
%	1. Largest Nested:	The largest nested watershed 
%	2. Multi-Nested:	All first-order nested watersheds
%
% INPUTS
% st_master	= master WS structure via WSWB_MASTER_STRUCT
% ID		= USGS ID of parent watershed
% ids		= USGS ids of nested watersheds [col vector]
% data_type	= string specifying data type in st_master
%			  e.g. 'R.d_cy.USGS' for Runoff / daily cy / USGS source
%		      calls: st_master(ii).R.d_cy.USGS
%
% OUTPUTS
% st
% TC Moran UC Berkeley 2013

%% PARAMETERS
MinAreaFraction = 0.05;
MinYears = 10;

%% PARENT WATERSHED 
idx = find([st_master(:).ID]==ID);
eval(['Years = st_master(idx).',data_type,'.year;']);
Area = st_master(idx).METADATA.ws.GAGESII.BASINID.DRAIN_SQKM;

%% ARRAY OF YEARS THAT OVERLAP PARENT RECORD
Nid = length(ids);
YEARS = zeros(length(Years),Nid);
for ii = 1:Nid
	idx = find([st_master(:).ID]==ids(ii));
	area(ii) = st_master(idx).METADATA.ws.GAGESII.BASINID.DRAIN_SQKM;
	if area(ii) >= Area*MinAreaFraction
		eval(['years = st_master(idx).',data_type,'.year;']);
		[~,idxYears,idxyears] = intersect(Years,years);
		if length(idxYears) >= MinYears
			YEARS(idxYears,ii) = years(idxyears);
		end
	end
end
%% REMOVE NESTED WS WITH NO OVERLAP WITH PARENT
ValidNested = find(max(YEARS,[],1)>0);
ids = ids(ValidNested);
YEARS = YEARS(:,ValidNested);
area = area(ValidNested);
if isempty(ids)
	st = [];
	return
end

%% SCENE 1: LARGEST OF VALID NESTED WATERSHEDS
[~,idx_large] = max(area);
st.LargestNested.id = ids(idx_large);
years_largest = YEARS(:,idx_large);
years_largest = years_largest(years_largest>0);
st.LargestNested.years = years_largest;
st.LargestNested.area_fraction_of_parent = area(idx_large)/Area;

%% SCENE 2: ALL NESTED WATERSHEDS 

%  Remove 2nd order nested watersheds
NestedWS = [];
for ii = 1:length(ids)
	% Eliminate any WS nested within other WS in 'ids'
	idx = find([st_master(:).ID]==ids(ii));
	NestedIDs = st_master(idx).NestedWS.IDs;
	chkNest(ii,:) = ~ismember(ids,NestedIDs);
end
ChkNest = logical(prod(chkNest,1));
ids_mult = ids(ChkNest);
area_mult = area(ChkNest);
YEARS = YEARS(:,ChkNest);
YEARS_mult = YEARS(min(YEARS,[],2)>0,1);
% only save if more than one nested WS left and interval longer than MinYears
if length(ids_mult) > 1 && length(YEARS_mult) >= MinYears	
	st.MultiNested.ids = ids_mult;
	st.MultiNested.years = YEARS_mult;
	st.MultiNested.area_fraction_of_parent = sum(area_mult)/Area;
else
	st.MultiNested.ids = [];
end
xx = 1;