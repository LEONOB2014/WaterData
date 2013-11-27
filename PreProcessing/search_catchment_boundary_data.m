function st_boundary = search_catchment_boundary_data(site_id,dir_boundary, dir_search)

% SEARCH_CATCHMENT_BOUNDARY_DATA(dir_catch_name) searches for previously
% processed boundary data in a 'boundary' subdirectory of the catchment
% directory 'dir_catch_name'
%
% INPUTS
% site_id     = name of catchment directory
% dir_search    = parent directory to search
%
% OUTPUTS
% st_boundary   = structure with boundary data
%
% TC Moran UC Berkeley 2012

%% INITIALIZE

% parent directory to search - should be directory where catchment data was
% previously analyzed
if nargin < 3
    dir_search = '/Users/tcmoran/Desktop/Catchment Analysis 2011/AA_CA_Catchments_Master/GAGESII_CATCHMENTS_CA';
    %     dir_search = '/Users/tcmoran/Desktop/Catchment Analysis 2011/AA_CA_Catchments_Master/DONE_ANALYSIS2';
    %     dir_search = uigetdir; % alternative to specifying path
end

%% SEARCH dir_catch WITHIN dir_search
dir_orig = cd(dir_search);
rdir_str = fullfile('*',['*',site_id,'*'],'boundary','ST_BOUNDARY_DATA.mat');

st_dir = rdir(rdir_str);
% if st_dir is empty, then there is no boundary data file found for this
% gage ID
if isempty(st_dir), st_boundary = []; return, end

%% IF BOUNDARY DATA ALREADY EXISTS, COPY DIR
dir_bound_source = fullfile(dir_search,fileparts(st_dir.name));
% search for key files present
fnames = get_file_names2(dir_bound_source);
fname_check = {'boundary_area_km2_ref_point_LatN_LonE_deg.txt',...
    'ST_BOUNDARY_DATA.mat','ST_GAGESII_METADATA.mat',...
    'boundary_line.kml'};
fchk = ismember(fname_check,fnames);
if min(fchk)==1
    copyfile(dir_bound_source,dir_boundary)
    fname_bound_data = fullfile(dir_search,st_dir.name);
    load(fname_bound_data)  % this will give us st_boundary
    return
end

%% IF BOUNDARY DATA ALREADY EXISTS, LOAD IT
fname_bound_data = fullfile(dir_search,st_dir.name);
load(fname_bound_data)  % this will give us st_boundary

%% SAVE BOUNDARY STRUCTURE
cd(dir_boundary)
save ST_BOUNDARY_DATA st_boundary

% Text files
Lat = st_boundary.Lat_degN;
Lon = st_boundary.Lon_degE;
LatLon = [Lat', Lon'];
dlmwrite('boundary_polygon_LatN_LonE_deg.txt',LatLon,'delimiter','\t','precision',9);

areakm2_LatLon_ref = [st_boundary.area_km2, st_boundary.ref_point.Latitude, st_boundary.ref_point.Longitude];
dlmwrite('boundary_area_km2_ref_point_LatN_LonE_deg.txt',areakm2_LatLon_ref,'delimiter','\t','precision',9)


%% SAVE A KML FILE
% move up one level to catchment directory
cd(dir_boundary)
write_boundary_kml('..')

cd(dir_orig)