function st_boundary = get_gagesII_boundary(dir_boundary,site_id)

% GET_GAGESII_BOUNDARY(dir_boundary,site_id,site_name) retrieves boundary
% data from USGS GAGESII streamflow gage characterization data set and
% saves a boundary data structure in dir_boundary. GAGESII data must be
% pre-processed into .mat files using preprocess_gagesII_shapefiles.m
%
% INPUTS
% dir_boundary  = absolute path to destination directory for boundary structure
% site_id       = gage site id code string
% site_name     = gage site name
%
% TC Moran UC Berkeley 2012

%% INITIALIZE

% absolute path to directory with pre-processed .mat boundary data
dir_boundary_data = '/Users/tcmoran/Desktop/Catchment Analysis 2011/_USGS GagesII Sep2011/boundaries-shapefiles-by-aggeco/MAT';
dir_boundary_point_data = '/Users/tcmoran/Desktop/Catchment Analysis 2011/_USGS GagesII Sep2011/gagesII_9322_point_shapefile';

fnames_mat = get_file_names2(dir_boundary_data,'.mat'); % list of all .mat files in this dir
fnames_id = find_full_string(fnames_mat,{'gage_ids'}); % list of gage_id files
fnames_data = find_full_string(fnames_mat,{},{'gage_ids'}); % list of boundary data files
% Sort both lists by ascending ASCII so that the indices match
fnames_id = sort(fnames_id');
fnames_data = sort(fnames_data');

%% FIND WHICH DATA FILE HOLDS THIS GAGE ID
dir_orig = cd(dir_boundary_data);
for ii = 1:length(fnames_id)
    fname_id = fnames_id{ii};
    load(fname_id)
    [chk_id, site_idx] = ismember(site_id,gage_ids);
    if chk_id
        file_idx = ii;
        break
    end
    
    % only get here if we haven't found the site id in any of the gage
    % lists
    if ii == length(fnames_id)
        display('Site ID not found in GAGESII Data Set')
        st_boundary = [];
        return
    end
end

%% GET BOUNDARY DATA FOR THIS SITE
fname_data = fnames_data{file_idx};
load(fname_data)    % loads boundary structure st_boundary
stb = st_boundary(site_idx);
% Make sure we got the right gage ID
gage_id = stb.GAGE_ID;
id_chk = strcmp(gage_id,site_id); % gage_id and site_id should by synonymous now
if ~id_chk, display('Site ID mismatch'), return, end % break out if no match

clear st_boundary

% Extract boundary data
Lat = stb.Lat;          % catchment boundary latitude coords (deg E)
Lon = stb.Lon;          % catchment boundary longitude coords (deg N)
ws_area_km2=stb.AREA/(1e6);   % catchment area (km^2)

%% IMPORT SITE POINT DATA
cd(dir_boundary_point_data)
% there should only be one .mat file here, with pre-processed point data
fname_pts = get_file_names2(dir_boundary_point_data,'.mat');
load(fname_pts{1}) % load point data structure st_points
% get index for this site_id in point structure
for idx_pt = 1:length(st_points)
    chk_pt = strcmp(st_points(idx_pt).STAID,site_id);
    if chk_pt 
        st_point = st_points(idx_pt);
        clear st_points
        break 
    end
    if idx_pt == length(st_points)
       display('GAGES II Point Data not found for this Site ID')
       st_boundary = [];
       return
    end
end

% Polygon centroid calc for reference point
pgeom = polygeom(Lon,Lat);    % polygon geometry
st_point.Centroid_Lat = pgeom(3);                % Centroid Lat
st_point.Centroid_Lon = pgeom(2);               % Centroid Lon

% Some downstream code expects different labels
st_point.Latitude = st_point.LAT_GAGE;
st_point.Longitude = st_point.LNG_GAGE;

%% STANDARD BOUNDARY STRUCTURE INFO

% Structure
st_boundary.Lat_degN = Lat;    % boundary polygon Lat coords (deg N)
st_boundary.Lon_degE = Lon;    % boundary polygon Lon coords (deg E)
st_boundary.area_km2 = ws_area_km2; % boundary polygon area (km2)
st_boundary.LatLon_projection = 'Geographic NAD27' ;  % boundary polygon projection info
st_boundary.shapefile = stb;        % boundary polygon shape file data (e.g. Albers X,Y)
st_boundary.shapefile.projection = 'NAD 1983 Albers';  % boundary polygon projection metadata
st_boundary.ref_point = st_point;        % boundary polygon watershed reference point metadata

% SAVE BOUNDARY STRUCTURE
cd(dir_boundary)
save ST_BOUNDARY_DATA st_boundary

% Text files
LatLon = [Lat', Lon'];
dlmwrite('boundary_polygon_LatN_LonE_deg.txt',LatLon,'delimiter','\t','precision',9);

areakm2_LatLon_ref = [ws_area_km2, st_point.LAT_GAGE, st_point.LNG_GAGE];
dlmwrite('boundary_area_km2_ref_point_LatN_LonE_deg.txt',areakm2_LatLon_ref,'delimiter','\t','precision',9)

%% SAVE A KML FILE
% move up one level to catchment directory
cd(dir_boundary)
write_boundary_kml('..')

%% ALSO GET GAGESII METADATA FOR THIS SITE
cd(dir_boundary)
fnames = get_file_names2(dir_boundary,'ST_GAGESII_METADATA.mat');
if isempty(fnames)
    make_gagesII_metadata_struct(site_id,dir_boundary)
end

cd(dir_orig)
