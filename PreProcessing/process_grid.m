function process_grid(dir_catch, data_source)

% PROCESS_GRID(catch_dir, data_source, data_type) does preprocessing for
% geospatial grid data calculations. Creates parent directory for grid
% products within catchment directory and calculates data mask for
% boundary polygon
%
% INPUTS
% catch_dir     = absolute path to catchment directory with 'boundary' subdir
% data_source   = string that identifies which type of data is being processed,
%                 e.g. 'PRISM' or 'MODIS'. Must correspond with type in
%                 get_data_type_info
%
% OUTPUTS
% GRID_TYPE subdirectory in catchment directory
% boundary data mask products within GRID_TYPE directory
%
% TC Moran UC Berkeley 2011

%% DEFAULT INPUT ARGUMENTS
if nargin < 1
    dir_catch = uigetdir;
end %if
%  default to PRISM for now
if nargin < 2
    data_source = 'PRISM';
end %if nargin

data_source = upper(data_source);
dir_orig = cd(dir_catch);
dir_data_source = ['GRID_',data_source];

%% CHECK IF GRID ALREADY PROCESSED 
fnames_dgrid = get_file_names2(dir_data_source,'ST_GRID_INFO_');
if ~isempty(fnames_dgrid)
    cd(dir_orig)
    return
end


%% CHECK IF GRID PREVIOUSLY PROCESSED ELSEWHERE ON THIS COMPUTER FOR THIS CATCHMENT
st_site_info = import_site_info('site_info.csv');
site_id_str = num2str(st_site_info.site_id);

% If we find a dir with the grid data for this catchment, just copy it over
% to the new location and be done. Also copies all subdirectories.
dir_grid_old = search_catchment_grid_files(site_id_str, data_source);
% 
% Check to make sure the catchment is the same by comparing the areas
area_thresh = 0.05;
if ~isempty(dir_grid_old)
    area_ref = st_site_info.ws_area_km2;  % reference area for this site (new area)
    % get area for old site
    dparts_old = dirparts(dir_grid_old);
    bound_file_old = fullfile(filesep,dparts_old{1:end-1},'boundary','boundary_area_km2_ref_point_LatN_LonE_deg.txt');
    bound_info_old = dlmread(bound_file_old);
    area_old = bound_info_old(1);
    Acheck = abs((area_ref/area_old)-1);
    if Acheck <= area_thresh;
        dir_grid_old = [dir_grid_old,'*'];
        copyfile(dir_grid_old, dir_catch)
        cd(fullfile(dir_catch,dir_data_source));
        % remove directories, preserve only grid files
        dir_list = get_dir_names2(pwd);
        for dd = 1:length(dir_list)
            rmdir(dir_list{dd},'s')
        end        
        cd(dir_orig)
        return
    end
end


%% IF GRID NOT ALREADY DONE, GET BOUNDARY INFO
boundary_dir = fullfile(dir_catch, 'boundary');
if isdir(boundary_dir)
    % Get watershed boundary structure
    st_boundary = get_boundary2(boundary_dir);
    if isempty(st_boundary)
        display(['No Boundary for Catchment ', site_id_str])
        return
    end
    
else
    uiwait(helpdlg({'Need a ''boundary'' directory with shape files for catchment';...
        site_name;...
        'Catchment will be skipped until this is done, yo.';...
        'Press okay, then insert the dir with shape files, then run again to consumate for this catchment.'}))
    pause(0.2)
    return
end %if ~isdir

%% PIXEL WEIGHTS, WRITE FILES TO GRID_SOURCE
if ~isdir(dir_data_source)
    mkdir(dir_data_source);
end

cd(dir_data_source);
dir_source = fullfile(dir_catch, dir_data_source); % data products directory

st_pixels = make_data_mask(dir_catch, st_boundary, data_source, dir_source);

save_name = ['ST_GRID_INFO_',data_source];
save_exp =  ['save ',save_name,' st_pixels'];
eval(save_exp)

cd(dir_orig)