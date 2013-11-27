function setup_catchment_analysis3(dir_parent, site_info_file)

% SETUP_CATCHMENT_ANALYSIS2 does directory setup and data pre-processing for
% catchment analysis, including automated boundary retrieval
%
% INPUTS
% site_info_file = absolute path to text file with rows of catchment (watershed) info
%                   [ws_num, ws_name, ws_parent, latN, latW, datum, area_km2]
% dir_parent      = absolute path to parent directory for catchment directories
% boundary_file_local_tf = flag (true/false) whether or not to import boundary
%                       from local shapefile
%
% TC Moran, UC Berkeley, 2011

%% DEFAULTS
if nargin < 1
    dir_parent = uigetdir;
end
dir_orig = cd(dir_parent);

if nargin < 2
    fnames1 = get_file_names;
    if ismember('site_info.txt',fnames1)
        site_info_file = fullfile(dir_parent, 'site_info.txt');
    else
        [fname,pname] = uigetfile('*.txt','Select site_info.txt file');
        site_info_file = fullfile(pname,fname);
    end
end

%% MAKE CATCHMENT DIRECTORIES
st_site_info = import_site_info(site_info_file);
num_sites = size(st_site_info,2);

for ss = 1:num_sites
    st_this_site_info = st_site_info(ss);
    site_dirs{ss} = make_site_dir2(st_this_site_info, dir_parent);
end %for ss

%% MAKE BOUNDARY DIRECTORIES IF NOT ALREADY PRESENT
for dd = 1:num_sites
    this_dir = site_dirs{dd};
    dir_last = cd(this_dir);
    if ~isdir('boundary')
        mkdir('boundary')
    end
end
cd(dir_parent)

%% CATCHMENT BOUNDARY

% Cycle through catchments
for ss = 1:num_sites
    st_this_site_info = st_site_info(ss);
    this_dir = site_dirs{ss};
    cd(this_dir)
    site_id_str = num2str(st_this_site_info.site_id);
    dir_boundary = fullfile(this_dir, 'boundary');
    
    % First check if boundary file is already there
    fnames_bound = get_file_names(dir_boundary);
    bound_st_fname = 'ST_BOUNDARY_DATA.mat';
    bound_kml_fname = 'boundary_line.kml';
    
    if ~isempty(fnames1) & ismember(bound_st_fname, fnames_bound) & ismember(bound_kml_fname,fnames_bound)
        continue
    end %if
    
    % Then try a search for a previously processed boundary for this site
    % on this computer
    st_boundary = search_catchment_boundary_data(site_id_str,dir_boundary);
    if ~isempty(st_boundary), continue, end
    
    % Then try to get the boundary from the USGS GAGESII Dataset
    % GAGESII Boundaries - Assume this curated set is the best source
    st_boundary = get_gagesII_boundary(dir_boundary,site_id_str);
    if ~isempty(st_boundary),
        continue
    end
    
    
    
    % Otherwise try remote retrieval from the UGSS Online service
%     st_boundary = get_USGS_online_boundary(this_dir); 
%     if isempty(st_boundary)
%         display(['No BOUNDARY data for site ID ',site_id_str])
%     end

end
cd(dir_parent)

%% CHECK CATCH AREAS FOR ALL CATCHMENTS IN PARENT DIRECTORY
% check_ws_area_mult(dir_parent)

cd(dir_orig)
