function process_runoff_mult(dir_parent,st_params)

% Get catchment dir names
catchment_dir_filter = 'CATCHMENT';
dir_catchments = get_dir_names2(dir_parent,catchment_dir_filter);

ncatch = length(dir_catchments);
% Cycle through each catchment
for cc = 1:ncatch
    dir_catch = fullfile(dir_parent,dir_catchments{cc});
    process_runoff_structure(dir_catch,st_params);
end