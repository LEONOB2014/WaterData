function process_grid_data_mult(dir_parent,grid_data_types,st_params)

% INPUTS
% dir_parent = absolute path to parent directory

%% INITIALIZE
catchment_dir_filter = 'CATCHMENT';
dir_catchments = get_dir_names2(dir_parent,catchment_dir_filter);

ncatch = length(dir_catchments);
ngrids = size(grid_data_types,2);

% specify first month of water year
wy_month1 = st_params.wy_month1;

%% CYCLE THROUGH CATCHMENTS
for cc = 1:ncatch
    dir_catch = fullfile(dir_parent,dir_catchments{cc});
    %% CYCLE THROUGH GRIDS
    for gg = 1:ngrids
        this_grid_data = grid_data_types{gg};
        this_grid = this_grid_data{1};
        
        %% CYCLE THROUGH DATA TYPES
        for dd = 2:length(this_grid_data)
            this_data = this_grid_data{dd};
            process_grid_data(dir_catch, this_grid, this_data, wy_month1);
        end
    end
end