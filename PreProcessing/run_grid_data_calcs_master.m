function run_grid_data_calcs_master(dir_master,calc_type)

% RUN_GRID_DATA_CALCS_MASTER(dir_master, calc_type) cycles through a master
% list or master directory with subdirectories that contain geospatial data
%
%
% TC Moran UC Berkeley 2012

%% INITIALIZE
if nargin < 1, dir_master = uigetdir; end
if nargin < 2, calc_type = 'AUTO'; end  % default to auto calc type


%% CYCLE THROUGH SUBDIRECTORIES
parent_dir_filter = 'HUC';

dir_parents = get_dir_names2(dir_master,parent_dir_filter); % list of subdirs

for pp = 1:length(dir_parents)
    dir_parent = fullfile(dir_master,dir_parents{pp});
    run_grid_data_calcs_mult(dir_parent,calc_type) 
    parent_dir_to_go = length(dir_parents) - pp
end