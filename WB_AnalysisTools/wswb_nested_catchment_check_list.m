function [ce_encompassing_catchs, ce_nearby_catchs,ce_nested_catchs, ce_nested_nearby_catchs] = wswb_nested_catchment_check_list(dir_master, flist)

% WSWB_NESTED_CATCHMENT_CHECK(dir_master,flist) looks for nested catchments
% within 'dir_master" from the list 'flist'
%
%
% TC Moran UC Berkeley 2012

%% INITIALIZE
if nargin < 1
    dir_master = WB_PARAMS('dir_master');
end
if nargin < 2
    flist = WB_PARAMS('wslist_ca219');
end
% get catchment list
dir_orig = cd(dir_master);
[ce_list_rel, ce_list_abs] = import_catchment_list(flist,dir_master);
ncatch = length(ce_list_rel);

%% CYCLE THROUGH CATCHMENT LIST
for cc = 1:ncatch
     display(['Parent Catchments To Go = ',num2str(ncatch-cc)])
     cd(ce_list_abs{cc})
     st_site = import_site_info('site_info.csv');
     LatLon = [st_site.site_latN, st_site.site_lonW];
     % catchments that encompass this site or are nearby
     [ce_encompassing_catchs{cc,1}, ce_nearby_catchs{cc,1}] = search_coords_inbound2(LatLon,ce_list_abs{cc},flist,dir_master);
     
     % Also find catchments nested within this catchment
     if ~isdir('boundary'); continue; end
    % move to boundary directory if it's there
    cd('boundary')
    stb = load('ST_BOUNDARY_DATA.mat');
    stb = stb.st_boundary;
    bLat = stb.Lat_degN;
    bLon = stb.Lon_degE;
    [ce_nested_catchs{cc,1},ce_nested_nearby_catchs{cc,1}] = search_nested_catchs2(bLat, bLon, LatLon(1),LatLon(2), ce_list_abs{cc}, dir_master, flist);
end

cd(dir_orig)