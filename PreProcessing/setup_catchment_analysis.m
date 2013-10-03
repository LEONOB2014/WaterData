function setup_catchment_analysis(site_info_file, dir_parent)

% SETUP_CATCHMENT_ANALYSIS does directory setup and data pre-processing for
% catchment analysis
%
% INPUTS
% site_info_file = absolute path to text file with rows of catchment (watershed) info
%                   [ws_num, ws_name, ws_parent, latN, latW, datum, area_km2]
% dir_parent      = absolute path to parent directory for catchment directories
%
% TC Moran, UC Berkeley, 2011

%% DEFAULTS
if nargin < 2
    dir_parent = uigetdir;
end 
if nargin < 1
    [fname,pname] = uigetfile('*.txt','Select site_info.txt file');
    site_info_file = fullfile(pname,fname);
end

%% PRE-PROCESS GEOSPATIAL DATA
preproc_PRISM('PRECIP')
preproc_PRISM('TMAX')
preproc_PRISM('TMIN')
preproc_PRISM('TDEW')


%% MAKE CATCHMENT DIRECTORIES
st_site_info = import_site_info(site_info_file);
num_sites = size(st_site_info,2);

for ss = 1:num_sites
    st_this_site_info = st_site_info(ss);
    site_dir{ss} = make_site_dir2(st_this_site_info, dir_parent);
end %for ss

%% PROCESS BOUNDARY DIRECTORIES IF PRESENT
for ss = 1:num_sites
    this_dir = site_dir{ss};
    last_dir = cd(this_dir);
    st_this_site_info = st_site_info(ss);
    site_name = st_this_site_info.site_name;
    site_id = st_this_site_info.site_id;
    boundary_dir = fullfile(this_dir, 'boundary');
    if isdir(boundary_dir)
        % Get watershed boundary structure
        st_boundary = get_boundary2(boundary_dir,site_id, site_name);
    else
        display(['No boundary directory for catchment ',site_name])
        pause(0.2)
        continue
    end %if ~isdir
end