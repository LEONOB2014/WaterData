function process_grid_master(dir_master,data_grids)

% INPUTS
% dir_master     = absolute path to master directory containing parent and
%                  catchment dirs
% 
% TC Moran UC Berkeley 2012

% Cycle through all parent directories in dir_master

parent_dir_filter = 'HUC';

dir_parents = get_dir_names2(dir_master,parent_dir_filter);

for pp = 1:length(dir_parents)
    dir_parent = fullfile(dir_master,dir_parents{pp});
    process_grid_mult(dir_parent,data_grids) 
    display([num2str(100*pp/length(dir_parents)),'% done'])
end