function val = WB_PARAMS(param_name)


%% DIRECTORIES
dir_master = '/Users/tcmoran/Desktop/Catchment Analysis 2011/AA_CA_Catchments_Master/GAGESII_CATCHMENTS_CA/GAGESII_CATCHMENTS_219';

dir_ghcn = '/Users/tcmoran/Desktop/IMWW/IMWW_DATA/CLIMATE_GHCND/IMWW_DATA/ghcnd_matlab';

%% WATERSHED LIST NAMES (relative paths)
wslist_ca219 = 'FILTERED_CATCHMENTS_219.txt';	% list of 219 CA watersheds that meet minimum criteria
wsinfo_ca219 = 'CA_site_info_filtered_219.txt'; % info list for 219 CA watersheds

%% DATA CRITERIA
MinDaysRwb = 355;									% min days of R for WB checks
MinDaysPwb = 355;
MinDaysGeneral = 355;

%% FLUX TYPES
flux_types = {'P','R','PET'};


%% FLUX SOURCES
sources_P = {'PRISM','VIC'};
sources_R = {'USGS'};
sources_PET = {'CIMIS','PRISM_Harg','PRISM_HargM'};

%% OUTPUT
eval(['val = ',param_name,';']);
xx = 1;								% debug line