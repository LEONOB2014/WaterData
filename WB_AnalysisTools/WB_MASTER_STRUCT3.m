function st_master = WB_MASTER_STRUCT3

% WB_MASTER_STRUCT2: A script to compile water balance variables into master variable
% structures


%% CATCHMENT LIST
mdir = WB_PARAMS('dir_master');
flist = WB_PARAMS('wslist_ca219');
fid = fopen(fullfile(mdir,flist));
Cdir = textscan(fid,'%s','Headerlines',1);
Cdir = Cdir{1};
fclose(fid);
NC = length(Cdir);
% Hydrol manipulation timeline
fname_timeline = 'CA_USGS_R_timeline_numbers.csv';
ws_timeline = csvread(fullfile(mdir,fname_timeline),1,0);


%% CYCLE THROUGH CATCHMENTS
daysRmin = 355;
for cc = 1:NC    
    cpath = fullfile(mdir,Cdir{cc});
	
	%% METADATA
    % load GAGESII
    Gpath = fullfile(cpath,'boundary','ST_GAGESII_METADATA.mat');
    s = load(Gpath);
    st.METADATA.ws.GAGESII = s.st_gagesII_metadata;
	st.ID = s.st_gagesII_metadata.BASINID.STAID;
	st.DIR = Cdir{cc};
	
	%% HYDROL DISTURB TIMELINE
	tidx = find(ws_timeline(:,1)==st.ID);
	cy_last_wb = ws_timeline(tidx,2);
	cy_last_loflo = ws_timeline(tidx,3);
	st.HYDROL_TIMELINE.WB_undisturbed_last = cy_last_wb;
	st.HYDROL_TIMELINE.LowFlow_undisturbed_last = cy_last_loflo;
	st.HYDROL_TIMELINE.Disturb_Confidence = ws_timeline(tidx,4);
	st.HYDROL_TIMELINE.Natural_Lakes_TF = ws_timeline(tidx,5);
	st.HYDROL_TIMELINE.Baseflow_Likely = ws_timeline(tidx,6);
	
	%% WATER BALANCE: VALIDATED WB YEARS
    WBpath = fullfile(cpath,'DATA_PRODUCTS','PRODUCT_PRDIFF_PRISMp_GAGEr.txt');
    WB = dlmread(WBpath,'\t',1,0);
	Nchk = WB(:,end)>=daysRmin;		% check for years with >10 days missing R data
	Tchk = WB(:,1) <= cy_last_wb;		% years before hydrol disturb
	NTchk = logical(Nchk.*Tchk);
	WB = WB(NTchk,:);
    st.WB.wy.PRISM_USGS.data = WB(:,2:end);
	st.WB.wy.PRISM_USGS.year = WB(:,1);
    st.WB.wy.PRISM_USGS.cols = 'P-Rmm Pmm Rmm NdaysR';
	st.WB.wy.PRISM_USGS.note = 'Years validated for NdaysR and Hydrol Disturb';
	
    %% RUNOFF: USGS
    RDpath = fullfile(cpath, 'GAGE_RUNOFF','ST_USGS_RUNOFF.mat');
    s = load(RDpath);
    stR = s.st_runoff;
    try
        Rd = stR.R_daily_cy_mm;		% daily
		Rm = stR.R_monthly_cy_mm;	% monthly
	catch
		Rd = stR.R_mean_daily_cy_mm;
		Rm = stR.R_mean_monthly_cy_mm;
	end
	Rcy = stR.cal_years;
	
	st.R.mo_cy.USGS.year = Rcy;
	st.R.mo_cy.USGS.data = Rm;
    st.R.d_cy.USGS.year =  Rcy;
	st.R.d_cy.USGS.data = Rd;
    	
	%% BASEFLOW
	Rb = baseflow_filter2(Rd,Rcy);
	st.Rb.d_cy.USGS.data = Rb;
	st.Rb.d_cy.USGS.year = Rcy;
	st.Rb.d_cy.USGS.units = 'mm daily';
	st.Rb.d_cy.USGS.note = 'Baseflow calculated with 1-parameter filter: baseflow_filter2.m';
	
    %% PRECIP: PRISM monthly precip
	Ppath = fullfile(cpath,'GRID_PRISM/GRID_PRISM_PRECIP','GRID_DATA_WY_MONTHLY_WEIGHTED_MEAN.txt');
    Pwy = dlmread(Ppath,'\t',2,0);	
	% CY only
	[Pcy,cysP] = wy2cy(Pwy(:,2:end-1),Pwy(:,1),'month',10);
	st.P.mo_cy.PRISM.data = Pcy;
	st.P.mo_cy.PRISM.year = cysP;
	st.P.mo_cy.PRISM.units = 'mm monthly';
	
	%% PRECIP: GHCN daily precip 
	if cc == 9
		xx = 1;
	end
	Ppath = fullfile(cpath,'GAGE_PRECIP_TEMP_GHCN','GHCN_PT_Daily.mat');
	s = load(Ppath);
	stp = s.st_PTdaily;
	% CY only
	[Pcy,cysP] = wy2cy(stp.P.wy_daily_mm,stp.P.wy,'day');
	st.P.d_cy.PRISM.data = Pcy;
	st.P.d_cy.PRISM.year = cysP;
	st.P.d_cy.PRISM.units= 'mm daily';
	st.P.d_cy.PRISM.notes= 'est from nearby GHCN daily';
	
	%% TEMP MONTHLY
	
	% GHCN daily temperature fluctuations
	st.Tmax.mo_cy.GHCN.data = stp.Tmax.monthly_frac_K;
	st.Tmax.mo_cy.GHCN.year = stp.Tmax.cy;
	st.Tmax.mo_cy.GHCN.data_info = 'Tdaily/mean(Tmonth) for temp in Kelvin';
	st.Tmin.mo_cy.GHCN.data = stp.Tmin.monthly_frac_K;
	st.Tmin.mo_cy.GHCN.year = stp.Tmin.cy;
	st.Tmax.mo_cy.GHCN.data_info = 'Tdaily/mean(Tmonth) for temp in Kelvin';
    
    %% PET: CIMIS
    Cpath = fullfile(cpath,'GRID_TEALE_ALBERS_2KM/GRID_TEALE_ALBERS_2KM_CIMIS_PET_YEARLY','GRID_DATA_WY_MONTHLY_WEIGHTED_MEAN.txt');
    CPET = dlmread(Cpath,'\t',2,0);
    CPET(CPET==0) = nan;
	% CY only
	[PETcy,cysPET] = wy2cy(CPET(:,2:end-1),CPET(:,1));
	st.PET.mo_cy.CIMIS.data = PETcy;
	st.PET.mo_cy.CIMIS.year = cysPET;
	
    %% PET: HARGREAVES
    Hpath = fullfile(cpath,'GRID_PRISM/GRID_PRISM_HPET/GRID_DATA_WY_MONTHLY_WEIGHTED_MEAN.txt');
    HPET = dlmread(Hpath,'\t',2,0);
    % CY only
	[PETcy,cysPET] = wy2cy(HPET(:,2:end-1),HPET(:,1));
	st.PET.mo_cy.PRISM_Harg.data = PETcy;
	st.PET.mo_cy.PRISM_Harg.year = cysPET;
	
    %% PET: HARGREAVES MODIFIED
    HMpath = fullfile(cpath,'GRID_PRISM/GRID_PRISM_HMPET/GRID_DATA_WY_MONTHLY_WEIGHTED_MEAN.txt');
    HMPET = dlmread(HMpath,'\t',2,0);
	% CY only
	[PETcy,cysPET] = wy2cy(HMPET(:,2:end-1),HMPET(:,1));
	st.PET.mo_cy.PRISM_HargM.data = PETcy;
	st.PET.mo_cy.PRISM_HargM.year = cysPET;
    
    %% LAND COVER: IGBP
    Ipath = fullfile(cpath,'GRID_MODIS_CA/GRID_MODIS_CA_BESS_IGBP','GRID_DATA_WY_CODE_AREA_FRACTION.txt');
    IGBP = dlmread(Ipath,'\t',2,0);
    st.LC.cy.IGBP.data = IGBP(:,2:end);
	st.LC.cy.IGBP.year = IGBP(:,1);	
    
    
    %% MODELS
    % import model parameters
    Mpath = fullfile(cpath,'DATA_PRODUCTS','ETo_aBb_stats.txt');
    M = dlmread(Mpath,'\t',1,0); % [ETd, a, B, b]
    st.MODELS.TriLin.params = M(1:4);
	st.MODELS.TriLin.params_info = 'ETd(mm),a(mm),B(mm/mm),b(mm)';
	st.MODELS.TriLin.errors = M(5:end);
	st.MODELS.TriLin.errors_info = 'RMSofRmodel(mm),RMSofP-R/Prms(mm),R2ofRmodel(~),R2ofP-R/P(~),R2ofR/P';
	
	%% MODEL OUTPUTS
	[Rmodel,Rresid,CE_Rresids] = trilin_RvP_calc(M(2),M(4),M(3),WB(:,3),WB(:,4));
	st.MODELS.TriLin.output.WY_OctSep.Rmodel = Rmodel;
	st.MODELS.TriLin.output.WY_OctSep.Rresid = Rresid;
	st.MODELS.TriLin.output.WY_OctSep.CE_Rresids = CE_Rresids;
	st.MODELS.TriLin.output.WY_OctSep.CE_Rresids_note = '{dry, mid, wet}';
	
    st_master(cc) = st;
    display([num2str(100*cc/NC),'% done'])
	
end

%% ESTIMATE FIRST DAY OF WATER YEAR (DOWY1)
st_master = wswb_calc_dowy1_master(st_master);

save(fullfile(mdir,'WB_MASTER.mat'),'st_master')
