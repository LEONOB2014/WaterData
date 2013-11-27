function plot_ws_data_mult(dir_parent)

% PLOT_WS_DATA_MULT(dir_parent) cycles through all catchment directories in
% dir_parent to make watershed water balance plots
%
% TC Moran UC Berkeley 2012

% Get catchment dir names
catchment_dir_filter = 'CATCHMENT';
dir_catchments = get_dir_names2(dir_parent,catchment_dir_filter);

ncatch = length(dir_catchments);
% Cycle through each catchment
for cc = 1:ncatch
    dir_catch = fullfile(dir_parent,dir_catchments{cc});
    plot_ws_data2(dir_catch);
end