function process_grid_data_master(dir_master,grid_data_types,st_params)

% PROCESS_GEOSPATIAL_DATA_MASTER(dir_master) performs geospatial
% data processing for all parent directories and site directories
% in dir_master
%
% INPUTS
% dir_master        = absolute path to master analysis directory
% grid_data_types   = cell array with data grid and type [1 x Ndata types]
%                     each data type {'GRID NAME','DATA NAME1','DATA NAME2'...}
% st_params         = data analysis parameter structure
% st_params.wy_month1 = first month of water year (e.g. 10 = Oct-Sep wy)
%
% TC Moran UC Berkeley 2012

%% INITIALIZE

% find parent dirs
dir_parents = get_dir_names2(dir_master,'HUC');
ndirs = length(dir_parents);

%% CYCLE THROUGH PARENT DIRECTORIES
for dd = 1:ndirs
    pdir_togo = ndirs-dd+1;
    display([num2str(pdir_togo), ' Grid Data Pdirs ToGo'])
    dir_parent = fullfile(dir_master,dir_parents{dd});
    process_grid_data_mult(dir_parent,grid_data_types,st_params)
end
