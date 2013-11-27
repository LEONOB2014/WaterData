function dir_old = search_catchment_grid_files(site_id, grid_type, dir_search)

% SEARCH_CATCHMENT_GRID_FILES(site_id, grid_type, dir_search) searches for previously
% processed boundary data in a 'boundary' subdirectory of the catchment
% directory 'dir_catch_name'
%
% INPUTS
% site_id     = name of catchment directory
% grid_type     = name of geospatial data grid to search
% dir_search    = parent directory to search
%
% OUTPUTS
% dir_old       = absolute path to old data directory
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
rdir_str = fullfile('*',['*',site_id,'*'],['GRID_',grid_type],['ST_GRID_INFO_',grid_type,'.mat']);
st_dir = rdir(rdir_str);
% if more than one, return only the first
if length(st_dir)>1
    st_dir = st_dir(1);
end

% if st_dir is empty, then the grid data cannot be found
if isempty(st_dir), dir_old = []; cd(dir_orig), return, end

%% IF GRID DATA ALREADY EXISTS, COPY IT
dir_grid_parts = dirparts(st_dir.name);
dir_old = fullfile(dir_search,dir_grid_parts{1:end-1}); % must exclude file name

cd(dir_orig)
