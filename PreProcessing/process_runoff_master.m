function process_runoff_master(dir_master,st_params)

% Cycle through all parent directories in dir_master

parent_dir_filter = 'HUC';
dir_parents = get_dir_names2(dir_master,parent_dir_filter);

for pp = 1:length(dir_parents)
    dir_parent = fullfile(dir_master,dir_parents{pp});
    process_runoff_mult(dir_parent,st_params) 
end