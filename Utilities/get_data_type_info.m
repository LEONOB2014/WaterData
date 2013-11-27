function st_data_type = get_data_type_info(data_source, data_type)

% GET_DATA_TYPE_INFO returns a structure with relevant info for the
% indicated data_type.
%
% INPUTS
% data_source = string that identifies source of data to be processed,
%             e.g. 'PRISM' or 'MODIS'.
% data_type   = string that identifies the type of data for the indicated
%               data source, e.g. 'precip', 'temp', 'et', 'pet', etc...
%
% OUTPUTS
% st_data_type                  = structure with relevant data info for subsquent processing
%             .dir_data_source  = full path to source data directory
%             .dir_data_product = full path to destination for data products
%             .data_units       = source data units
%             .data_filename    = file name of source data
%
% TC Moran UC Berkeley 2011

data_source = upper(data_source);
data_type   = upper(data_type);

switch data_source
    %% PRISM-derived data
    case 'PRISM'
        
        % PRISM data directory ***PLATFORM DEPENDENCY***
        st.data_source = data_source;
        st.data_type   = upper(data_type);
        
        if strcmp(data_type,'PRECIP');
            % Location of source data 
            st.dir_data_source  = '/Users/tcmoran/Desktop/Catchment Analysis 2011/PRISM Data/Precip Data/PRISM/PRISM DOWNLOAD 10MAY11/CONSOLIDATED';
            st.dir_data_product = [data_source,'_',data_type]; % name of subdir for PRISM data products
            st.data_units       = 'mm';
            st.data_NaN         = -9999;
            st.data_filename    = 'us_ppt_YYYY.MM.grd';  % YYYY = year, MM = month
            st.data_mat_fname   = 'ST_PRISM_PRECIP_CY_YYYY.mat';
            st.yearly_tot_type  = 'sum';
        
        elseif strcmp(data_type,'TMAX')
            st.dir_data_source  = '/Users/tcmoran/Desktop/Catchment Analysis 2011/PRISM Data/Temp Data/Tmax/Consolidated';
            st.dir_data_product = [data_source,'_',data_type]; % name of subdir for PRISM data products
            st.data_units       = 'degC*100';
            st.data_NaN         = -9999;
            st.data_filename    = 'us_tmax_YYYY.MM';  % YYYY = year, MM = month
            st.data_mat_fname   = 'ST_PRISM_TMAX_CY_YYYY.mat';
            st.yearly_tot_type  = 'avg';
            
        elseif strcmp(data_type,'TMIN')
            st.dir_data_source  = '/Users/tcmoran/Desktop/Catchment Analysis 2011/PRISM Data/Temp Data/Tmin/Consolidated';
            st.dir_data_product = [data_source,'_',data_type]; % name of subdir for PRISM data products
            st.data_units       = 'degC*100';
            st.data_NaN         = -9999;
            st.data_filename    = 'us_tmin_YYYY.MM';  % YYYY = year, MM = month  
            st.data_mat_fname   = 'ST_PRISM_TMIN_CY_YYYY.mat';
            st.yearly_tot_type  = 'avg';
            
        elseif strcmp(data_type,'TDEW')
            st.dir_data_source  = '/Users/tcmoran/Desktop/Catchment Analysis 2011/PRISM Data/Temp Data/Td/Consolidated';
            st.dir_data_product = [data_source,'_',data_type]; % name of subdir for PRISM data products
            st.data_units       = 'degC*100';
            st.data_NaN         = -9999;
            st.data_filename    = 'us_tdmean_YYYY.MM';  % YYYY = year, MM = month 
            st.data_mat_fname   = 'ST_PRISM_TDEW_CY_YYYY.mat';
            st.yearly_tot_type  = 'avg';
        
        elseif strcmp(data_type,'HPET')
            st.dir_data_source  = '/Users/tcmoran/Desktop/Catchment Analysis 2011/PRISM Data/PET Data Hargreaves/';
            st.dir_data_product = [data_source,'_',data_type]; % name of subdir for PRISM data products
            st.data_units       = 'mm';
            st.data_NaN         = -9999;
            st.data_filename    = 'ST_PRISM_PET_H_CY_YYYY.mat'; %YYYY = year
            st.data_mat_fname   = 'ST_PRISM_PET_H_CY_YYYY.mat';
            st.yearly_tot_type  = 'sum';
            
        elseif strcmp(data_type,'HMPET')
            st.dir_data_source  = '/Users/tcmoran/Desktop/Catchment Analysis 2011/PRISM Data/PET Data Hargreaves Modified';
            st.dir_data_product = [data_source,'_',data_type]; % name of subdir for PRISM data products
            st.data_units       = 'mm';
            st.data_NaN         = -9999;
            st.data_filename    = 'ST_PRISM_PET_HM_CY_YYYY.mat'; %YYYY = year
            st.data_mat_fname   = 'ST_PRISM_PET_HM_CY_YYYY.mat';
            st.yearly_tot_type  = 'sum';    
        end
   
    %% Advanced Very High Resolution Radiometer 
    % Data derived from AVHRR, including UMont ET grid
    case 'AVHRR'
        st.data_source = data_source;
        st.data_type   = upper(data_type);
        
        if strcmp(data_type,'UMONT_ET');
            % Location of source data 
            st.dir_data_source  = '/Users/tcmoran/Desktop/Catchment Analysis 2011/ET DATA SETS/UM Sat ET/Global_8kmResolution/MAT_DATA';
            st.dir_data_product = [data_source,'_',data_type]; % name of subdir for PRISM data products
            st.data_units       = 'mm';
            st.data_NaN         = -9999;
            st.data_filename    = '';  % YYYY = year, MM = month
            st.data_mat_fname   = 'Global_monthly_ET_YYYY.mat';
            st.yearly_tot_type  = 'sum';
        end
        
    %% USA 0.05 DEGREE GRID 
    %  Data grids using 0.05 degree USA grid, including UW ET grid
    case 'USA05' 
        st.data_source = data_source;
        st.data_type   = upper(data_type);
        
        if strcmp(data_type,'UW_ET');
            % Location of source data 
            st.dir_data_source  = '/Users/tcmoran/Desktop/Catchment Analysis 2011/ET DATA SETS/UW Global ET/usa/UW_ET0.05 Folder/MAT_DATA';
            st.dir_data_product = [data_source,'_',data_type]; % name of subdir for PRISM data products
            st.data_units       = 'mm';
            st.data_NaN         = -9999;
            st.data_filename    = '';  % YYYY = year, MM = month
            st.data_mat_fname   = 'UW_ET_Monthly_YYYY.mat';
            st.yearly_tot_type  = 'sum';
        end
        
    %% MODIS    
    case 'MODIS_CA'
        st.data_source = data_source;
        st.data_type   = upper(data_type);
        
        if strcmp(data_type,'BESS_ET');
            % Location of source data 
            st.dir_data_source  = '/Users/tcmoran/Desktop/Catchment Analysis 2011/ET DATA SETS/Bess';
            st.dir_data_product = [data_source,'_',data_type]; % name of subdir for PRISM data products
            st.data_units       = 'mm';
            st.data_NaN         = -9999;
            st.data_filename    = '';  % YYYY = year, MM = month
            st.data_mat_fname   = 'BESS_ET_CY_YYYY.mat';
            st.yearly_tot_type  = 'sum';
        end

        if strcmp(data_type,'BESS_IGBP');
            % Location of source data 
            st.dir_data_source  = '/Users/tcmoran/Desktop/Catchment Analysis 2011/ET DATA SETS/Bess';
            st.dir_data_product = [data_source,'_',data_type]; % name of subdir for PRISM data products
            st.data_units       = 'code_igbp';
            st.data_filename    = '';  % YYYY = year, MM = month
            st.data_mat_fname   = 'BESS_IGBP_CY_YYYY.mat';
            st.yearly_tot_type  = 'code_igbp';
        end
    
    %% TEALE ALBERS 2KM GRIDS    
    case 'TEALE_ALBERS_2KM'
        
        st.data_source = data_source;
        st.data_type   = upper(data_type);
        
        if strcmp(data_type,'CIMIS_PET');
            % Location of source data 
            st.dir_data_source  =  '/Users/tcmoran/Desktop/2012 Catchment Analysis/CIMIS Data/PET/Monthly Averages';
            st.dir_data_product = [data_source,'_',data_type]; % name of subdir for PRISM data products
            st.data_units       = 'mm';
            st.data_NaN         = NaN;
            st.data_filename    = '';  % YYYY = year, MM = month
            st.data_mat_fname   = 'ST_CIMIS_CY_AVG_MONTHLY_TOT.mat';
            st.yearly_tot_type  = 'sum';
        end
        
        if strcmp(data_type,'CIMIS_PET_YEARLY');
            % Location of source data 
            st.dir_data_source  =  '/Users/tcmoran/Desktop/2012 Catchment Analysis/CIMIS Data/PET/YYYY_MM_averages';
            st.dir_data_product = [data_source,'_',data_type]; % name of subdir for PRISM data products
            st.data_units       = 'mm';
            st.data_NaN         = NaN;
            st.data_filename    = '';  % YYYY = year, MM = month
            st.data_mat_fname   = 'ST_CIMIS_PET_CY_YYYY.mat';
            st.yearly_tot_type  = 'sum';
        end
        
        
    case 'VIC_CA'
        
        st.data_source = data_source;
        st.data_type   = upper(data_type);
        
        if strcmp(data_type,'PRECIP');
            % Location of source data 
            st.dir_data_source  =  '/Users/tcmoran/Documents/ENV_DATA/Precipitation/VIC/2005 study';
            st.dir_data_product = [data_source,'_',data_type]; % name of subdir for PRISM data products
            st.data_units       = 'mm';
            st.data_NaN         = NaN;
            st.data_filename    = '';  % YYYY = year, MM = month
            st.data_mat_fname   = 'ST_VIC_PRECIP_CY_MONTHLY_YYYY.mat';
            st.yearly_tot_type  = 'sum';
        end
        
end

st_data_type = st;