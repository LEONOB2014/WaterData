function RUN_CATCHMENT_PROCESSING_MASTER(dir_master, catchment_list_master,st_params)

% RUN_CATCHMENT_PROCESSING_MASTER(dir_master, catchment_list_master,st_params) executes
% watershed water balance analysis.
%
% INPUTS
% dir_master    = path to master directory for watershed analysis
% catchment_list_master = absolute path to master catchment list text file
% st_analysis_params = structure with specified analysis parameters
%
% TC Moran UC Berkeley 2012

%% INITIALIZE
if nargin < 1, dir_master = WB_PARAMS('dir_master'); end
% dir_orig = cd(dir_master);

if nargin < 2
	catchment_list_master = fullfile(dir_master,WB_PARAMS('wsinfo_ca219'));
% 	[fname,pname] = uigetfile('*.txt;*.csv');
%     catchment_list_master = fullfile(pname,fname);
end
mlist = catchment_list_master;
if nargin < 3
    st_params.wy_month1 = 10;   % specify October as the default first month of water year
    st_params.wy_day1 = firstdayofmonth(st_params.wy_month1);
end

%% CHECK THAT GEOSPATIAL SOURCE DATA HAS BEEN PRE-PROCESSED
preproc_PRISM('PRECIP')
preproc_PRISM('TMAX')
preproc_PRISM('TMIN')
preproc_PRISM('TDEW')
run_prism_pet_hargreaves3(1895:2012)
run_prism_pet_hargreaves_mod(1895:2012)

%% CIMIS data
% query_CIMIS_eto;
% process_CIMIS_PET_yearly_script
% 
% 
% cd(dir_master)

%% MAKE DIRECTORY STRUCTURE
Parent Directories
make_parent_dirs(mlist, dir_master)

%% CATCHMENT SETUP
setup_catchment_analysis3_mult(dir_master)

%% GEOSPATIAL GRID PROCESSING
% data_grids = {'PRISM','MODIS_CA','TEALE_ALBERS_2KM','VIC_CA'};
% data_grids = {'PRISM','AVHRR','USA05','MODIS_CA','TEALE_ALBERS_2KM'};
data_grids = {'PRISM','MODIS_CA','TEALE_ALBERS_2KM','VIC_CA'};
% data_grids = {'TEALE_ALBERS_2KM'};

process_grid_master(dir_master,data_grids)


%% GEOSPATIAL DATA PROCESSING
% Specify data grid and data type
% *format:  {'GRID_TYPE', 'DATA_TYPE(1)', 'DATA_TYPE(2)'... 'DATA_TYPE(N)'}
% 
% data_grid_type{1} = {'PRISM','HPET'}
data_grid_type{1} = {'PRISM','PRECIP','TMAX','TMIN','HPET','HMPET'};
data_grid_type{2} = {'MODIS_CA','BESS_IGBP'};
% data_grid_type{1} = {'TEALE_ALBERS_2KM','CIMIS_PET_YEARLY'};
data_grid_type{3} = {'VIC_CA','PRECIP'};
% data_grid_type{1} = {'PRISM','PRECIP','HPET','TDEW','TMAX','TMIN','HMPET'};
% data_grid_type{2} = {'AVHRR','UMONT_ET'};
% data_grid_type{3} = {'USA05','UW_ET'};
% data_grid_type{4} = {'MODIS_CA','BESS_ET','BESS_IGBP'};

%% GRID DATA PROCESSING
% process_grid_data_master(dir_master,data_grid_type,st_params)
% *** code runs faster with one type at a time since loads from RAM instead
% of HD ***
ng = length(data_grid_type);
for gg = 1:ng
    dgtype = data_grid_type{gg};
    gtype = dgtype{1};
    nt = length(dgtype);
    for tt = 2:nt
        DGtype = {{gtype,dgtype{tt}}};
        process_grid_data_master(dir_master,DGtype,st_params)
    end
end

%% GRID DATA CALCULATIONS, E.G. WEIGHTED MEAN
run_grid_data_calcs_master(dir_master)

%% RUNOFF DATA PROCESSING
process_runoff_master(dir_master,st_params)

%% HUC BOUNDARIES
% Make directories with huc boundary data
setup_huc_boundary(dir_master)
plot_huc_boundary(dir_master)

%% WATER BALANCE CALCULATIONS
calc_ws_products2_master(dir_master)

%% MAKE WATER BALANCE PLOTS
plot_ws_data_master(dir_master)
