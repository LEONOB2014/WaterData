function process_grid_mult(dir_parent,data_grids)

% INPUTS
% dir_parent = absolute path to parent directory

catchment_dir_filter = 'CATCHMENT';

dir_catchments = get_dir_names2(dir_parent,catchment_dir_filter);

ncatch = length(dir_catchments);
ngrids = length(data_grids);
% Cycle through each catchment
for cc = 1:ncatch
    dir_catch = fullfile(dir_parent,dir_catchments{cc});
    % Cycle through each grid
    for gg = 1:ngrids
        this_grid = data_grids{gg};
        process_grid(dir_catch, this_grid);
    end
end