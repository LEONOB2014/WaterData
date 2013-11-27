function plot_ws_data_master(dir_master)

% PLOT_WS_DATA_MASTER(dir_master) cycles through all parent directories in
% dir_master to make watershed water balance plots for all catchments in
% each parent dir
%
% TC Moran UC Berkeley 2012

parent_dir_filter = 'HUC';
dir_parents = get_dir_names2(dir_master,parent_dir_filter);

for pp = 1:length(dir_parents)
    dir_parent = fullfile(dir_master,dir_parents{pp});
    plot_ws_data_mult(dir_parent) 
end