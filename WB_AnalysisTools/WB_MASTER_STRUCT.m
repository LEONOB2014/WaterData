function st_master = WB_MASTER_STRUCT

% WB_MASTER A script to compile water balance variables into master variable
% structures

%% CATCHMENT LIST
mdir = '/Users/tcmoran/Desktop/Catchment Analysis 2011/AA_CA_Catchments_Master/GAGESII_CATCHMENTS_CA/GAGESII_CATCHMENTS_219';
flist = 'FILTERED_CATCHMENTS_219.txt';
fid = fopen(fullfile(mdir,flist));
Cdir = textscan(fid,'%s','Headerlines',1);
Cdir = Cdir{1};
fclose(fid);
NC = length(Cdir);


%% CYCLE THROUGH CATCHMENTS
for cc = 1:length(Cdir)    
    cpath = fullfile(mdir,Cdir{cc});
    
    %% RUNOFF
    % import monthly R    
    Rpath = fullfile(cpath, 'GAGE_RUNOFF','RUNOFF_QGAGE_yr_mo_R.txt');
    Rmo = dlmread(Rpath,'\t',1,0);
    st.R.mo_wy.USGS = Rmo;
    
    % import R daily
    RDpath = fullfile(cpath, 'GAGE_RUNOFF','ST_USGS_RUNOFF.mat');
    load(RDpath)
    str = st_runoff;
    try
        Rd = str.R_daily_wy_mm;
    catch
        Rd = str.R_mean_daily_wy_mm;
    end
    Rdwy = str.water_years;
    Rd = str.R_daily_wy_mm;
    st.R.d_wy.USGS = [Rdwy,Rd];
    
    %% PRECIP
    % import PRISM precip
    Ppath = fullfile(cpath,'GRID_PRISM/GRID_PRISM_PRECIP','GRID_DATA_WY_MONTHLY_WEIGHTED_MEAN.txt');
    Pwy = dlmread(Ppath,'\t',2,0);
    st.P.mo_wy.PRISM = Pwy(:,1:end-1);
    
    %% PET
    % import CIMIS PET
    Cpath = fullfile(cpath,'GRID_TEALE_ALBERS_2KM/GRID_TEALE_ALBERS_2KM_CIMIS_PET_YEARLY','GRID_DATA_WY_MONTHLY_WEIGHTED_MEAN.txt');
    CPET = dlmread(Cpath,'\t',2,0);
    CPET(CPET==0) = nan;
    st.PET.mo_wy.CIMIS = CPET(:,1:end-1);
    
    % import HPET
    Hpath = fullfile(cpath,'GRID_PRISM/GRID_PRISM_HPET/GRID_DATA_WY_MONTHLY_WEIGHTED_MEAN.txt');
    HPET = dlmread(Hpath,'\t',2,0);
    st.PET.mo_wy.PRISM_Harg = HPET(:,1:end-1);
    
    % import HMPET
    HMpath = fullfile(cpath,'GRID_PRISM/GRID_PRISM_HMPET/GRID_DATA_WY_MONTHLY_WEIGHTED_MEAN.txt');
    HMPET = dlmread(HMpath,'\t',2,0);
    st.PET.mo_wy.PRISM_HargM = HMPET(:,1:end-1);

    
    %% LAND COVER
    % import IGBP data
    Ipath = fullfile(cpath,'GRID_MODIS_CA/GRID_MODIS_CA_BESS_IGBP','GRID_DATA_WY_CODE_AREA_FRACTION.txt');
    IGBP = dlmread(Ipath,'\t',2,0);
    st.LC.cy.IGBP = IGBP;
    
    %% WATER BALANCE
    % import WB data (validated WB years)
    WBpath = fullfile(cpath,'DATA_PRODUCTS','PRODUCT_PRDIFF_PRISMp_GAGEr.txt');
    WB = dlmread(WBpath,'\t',1,0);
    st.WB.wy.PRISM_USGS = WB;
    
    %% METADATA
    % load GAGESII
    Gpath = fullfile(cpath,'boundary','ST_GAGESII_METADATA.mat');
    load(Gpath)
    st.METADATA.ws.GAGESII = st_gagesII_metadata;
    
    %% MODELS
    % import model parameters
    Mpath = fullfile(cpath,'DATA_PRODUCTS','ETo_aBb_stats.txt');
    M = dlmread(Mpath,'\t',1,0); % [ETd, a, B, b]
    st.MODEL.RofP = M;
    
    % **** still debugging contents ****
    
    ST(cc) = st;
    
    
end

