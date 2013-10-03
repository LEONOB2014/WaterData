function run_grid_data_calcs_mult(dir_parent,calc_type)

% RUN_GRID_DATA_CALCS_MULT(dir_parent, calc_type) 
%
% TC Moran UC Berkeley 2012

%% INITIALIZE
if nargin < 1, dir_parent = uigetdir; end
if nargin < 2, calc_type = 'AUTO'; end   % default to automatic calc type

%% CYCLE THROUGH CATCHMENT DIRECTORIES
catchment_dir_filter = 'CATCHMENT';

dir_catchments = get_dir_names2(dir_parent,catchment_dir_filter);

ncatch = length(dir_catchments);
% Cycle through each catchment
parfor cc = 1:ncatch
    dir_catch = fullfile(dir_parent,dir_catchments{cc});
    % Make list of grids in this catchment
    run_grid_data_calcs(dir_catch, calc_type);
end