function st_master = WSWB_MASTER_STRUCT(st_master)

% WB_MASTER_STRUCT2: A script to compile water balance variables into master variable
% structures


%% INITIALIZE
mdir = WB_PARAMS('dir_master');
flist = WB_PARAMS('wslist_ca219');
Cdir = import_catchment_list(fullfile(mdir,flist), mdir);
NC = length(Cdir);
MinDaysRwb = WB_PARAMS('MinDaysRwb');

% Hydrol manipulation timeline
fname_timeline = 'CA_USGS_R_timeline_numbers.csv';
ws_timeline = csvread(fullfile(mdir,fname_timeline),1,0);

%% CYCLE THROUGH CATCHMENTS
Nstart = 1;
% hf = figure; ha = gca; hold on, box on, xlabel('count'), ylabel('Mins to go')
% tic
for cc = Nstart:NC
	cpath = fullfile(mdir,Cdir{cc});
	st = struct;
	
	%% METADATA
	st = get_metadata(st,cpath,Cdir{cc});
	
	%% HYDROL DISTURB TIMELINE
	st = get_hydrol_timeline(st,ws_timeline);
	
	%% WATER BALANCE: VALIDATED WB YEARS
	st = get_wb_oct(st,cpath,MinDaysRwb);
	
	%% RUNOFF: USGS
	st = get_r_usgs(st,cpath);
	
	%% BASEFLOW
	st = get_rb(st);
	
	%% PRECIP: PRISM monthly precip
	st = get_p_prism_mo(st,cpath);
	
	%% PRECIP: GHCN and PRISM daily precip
	st = get_p_prism_ghcn_day(st,cpath);
	
	%% PRECIP: VIC MONTHLY
	st = get_p_vic_mo(st,cpath);
	
	%% PET: CIMIS
	st = get_pet_cimis_mo(st,cpath);
	
	%% PET: HARGREAVES
	st = get_pet_harg_mo(st,cpath);
	
	%% PET: HARGREAVES MODIFIED
	st = get_pet_hargm_mo(st,cpath);
	
	%% TEMP FLUCTUATIONS
	st = get_temp_fluc_day(st,cpath);
	
	%% ESTIMATE FIRST DAY OF WATER YEAR (DOWY1)
	st = wswb_calc_dowy1_master(st);
	
	%% Rb: VALUE ON DOWY1
	st = get_Rb_dowy1(st);
	
	%% Rb: RECESSION SLOPE
	st = calc_Rb_recession_slope(st);
	
	%% dS: ESTIMATE YEARLY dS FROM RECESSION SLOPE AND dQ
	st = calc_dS_yearly(st);
	
	%% CALCULATE WATER YEAR TOTALS
	% 	st = wswb_calc_wb_wy(st);
	st = calc_wytot(st);
	
	%% CALCULATE SCALED VIC PRECIP
	st = wswb_P_VIC_scaledby_PRISM(st);
	
	%% LAND COVER: IGBP
	st = get_lc_igbp(st,cpath);
	
	%% FIND WS NESTED IN CURRENT WS
	st = find_nested_ws(st);
% 	Nnest(cc,1) = length(st.NestedWS.IDs);
	
	%% LIST of NEARBY GHCN STATIONS
	st = get_ghcn_nearby(st);
	
	%% GHCN STATION WITH BEST LINEAR FIT TO LUMPED ANNUAL PRISM
	st = get_ghcn_best(st);
	
	%% MODEL PARAMETERS
	st = get_model_params_trilin(st,cpath);
	
	%% MODEL OUTPUTS
	% OCT-SEP WY
	P = st.WB.wy.PRISM_USGS.data(:,2);
	R = st.WB.wy.PRISM_USGS.data(:,3);
	wb_type = 'WY_OctSep_PRISM_USGS';
	st = get_model_output_trilin(st,P,R,wb_type);
	
	st_master(cc) = st;
	
% 	dt = toc;
% 	Ttogo = progress_time(cc,NC,dt,'min',true);
% 	scatter(ha,cc,Ttogo,'ro','filled')
	display([num2str(100*cc/NC),'% done'])
end
% close(hf)

xx = 1;
%% CALCULATIONS THAT REQUIRE DATA FROM MULTIPLE WATERSHEDS
for cc = Nstart:NC
	st = st_master(cc);
	%% CALCULATE FLUX VALUES INDEPENDENT OF NESTED WATERSHEDS
	st = get_nested_scenes(st,st_master);
	
	%% CALCULATE FLUXES WITHOUT NESTED WATERSHEDS
	st = calc_fluxes_nonnested(st,st_master);
	
	st_master(cc) = st;
end
xx = 1;
save(fullfile(mdir,'WSWB_MASTER.mat'),'st_master')

function st = get_metadata(st,cpath,cdir)	% LOAD GAGESII METADATA
Gpath = fullfile(cpath,'boundary','ST_GAGESII_METADATA.mat');
s = load(Gpath);
st.METADATA.ws.GAGESII = s.st_gagesII_metadata;
st.ID = s.st_gagesII_metadata.BASINID.STAID;
st.DIR = cdir;

function st = get_hydrol_timeline(st,ws_timeline)	% LOAD HYDROL TIMELINE
tidx = find(ws_timeline(:,1)==st.ID);
cy_last_wb = ws_timeline(tidx,2);
cy_last_loflo = ws_timeline(tidx,3);
st.HYDROL_TIMELINE.WB_undisturbed_last = cy_last_wb;
st.HYDROL_TIMELINE.LowFlow_undisturbed_last = cy_last_loflo;
st.HYDROL_TIMELINE.Disturb_Confidence = ws_timeline(tidx,4);
st.HYDROL_TIMELINE.Natural_Lakes_TF = ws_timeline(tidx,5);
st.HYDROL_TIMELINE.Baseflow_Likely = ws_timeline(tidx,6);

function st = get_wb_oct(st,cpath,MinDaysRwb)	% LOAD OCT-SEP YEARLY WB
WBpath = fullfile(cpath,'DATA_PRODUCTS','PRODUCT_PRDIFF_PRISMp_GAGEr.txt');
WB = dlmread(WBpath,'\t',1,0);
Nchk = WB(:,end)>=MinDaysRwb;		% check for years with >10 days missing R data
cy_last_wb = st.HYDROL_TIMELINE.WB_undisturbed_last;
Tchk = WB(:,1) <= cy_last_wb;		% years before hydrol disturb
NTchk = logical(Nchk.*Tchk);
WB = WB(NTchk,:);
st.WB.wy.PRISM_USGS.data = WB(:,2:end);
st.WB.wy.PRISM_USGS.year = WB(:,1);
st.WB.wy.PRISM_USGS.cols = 'P-Rmm Pmm Rmm NdaysR';
st.WB.wy.PRISM_USGS.note = 'Years validated for NdaysR and Hydrol Disturb';

function st = get_r_usgs(st,cpath)	% LOAD USGS DAILY R
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

function st = get_rb(st)		% CALCULATE BASEFLOW Rb
Rd = st.R.d_cy.USGS.data;
Rcy = st.R.mo_cy.USGS.year;
Rb = baseflow_filter2(Rd,Rcy);
st.Rb.d_cy.USGS.data = Rb;
st.Rb.d_cy.USGS.year = Rcy;
st.Rb.d_cy.USGS.units = 'mm daily';
st.Rb.d_cy.USGS.note = 'Baseflow calculated with 1-parameter filter: baseflow_filter2.m';

function st = get_p_prism_mo(st,cpath)	% LOAD P MONTHLY, PRISM
Ppath = fullfile(cpath,'GRID_PRISM','GRID_PRISM_PRECIP','GRID_DATA_WY_MONTHLY_WEIGHTED_MEAN.txt');
Pwy = dlmread(Ppath,'\t',2,0);
% CY only
[Pcy,cysP] = wy2cy(Pwy(:,2:end-1),Pwy(:,1),'month',10);
st.P.mo_cy.PRISM.data = Pcy;
st.P.mo_cy.PRISM.year = cysP;
st.P.mo_cy.PRISM.units = 'mm monthly';

function st = get_p_prism_ghcn_day(st,cpath)	% LOAD P DAILY, PRISM/GHCN
Ppath = fullfile(cpath,'GAGE_PRECIP_TEMP_GHCN','GHCN_PT_Daily.mat');
s = load(Ppath);
stp = s.st_PTdaily;
% CY only
[Pcy,cysP] = wy2cy(stp.P.wy_daily_mm,stp.P.wy,'day');
st.P.d_cy.PRISM.data = Pcy;
st.P.d_cy.PRISM.year = cysP;
st.P.d_cy.PRISM.units= 'mm daily';
st.P.d_cy.PRISM.notes= 'est from nearby GHCN daily';

function st = get_temp_fluc_day(st,cpath)		% LOAD TEMP DAILY FLUC
Ppath = fullfile(cpath,'GAGE_PRECIP_TEMP_GHCN','GHCN_PT_Daily.mat');
s = load(Ppath);
stp = s.st_PTdaily;
% GHCN daily temperature fluctuations
st.Tmax.mo_cy.GHCN.data = stp.Tmax.monthly_frac_K;
st.Tmax.mo_cy.GHCN.year = stp.Tmax.cy;
st.Tmax.mo_cy.GHCN.data_info = 'Tdaily/mean(Tmonth) for temp in Kelvin';
st.Tmin.mo_cy.GHCN.data = stp.Tmin.monthly_frac_K;
st.Tmin.mo_cy.GHCN.year = stp.Tmin.cy;
st.Tmax.mo_cy.GHCN.data_info = 'Tdaily/mean(Tmonth) for temp in Kelvin';

function st = get_pet_cimis_mo(st,cpath)		% LOAD PET MONTHLY, CIMIS
Cpath = fullfile(cpath,'GRID_TEALE_ALBERS_2KM/GRID_TEALE_ALBERS_2KM_CIMIS_PET_YEARLY','GRID_DATA_WY_MONTHLY_WEIGHTED_MEAN.txt');
CPET = dlmread(Cpath,'\t',2,0);
CPET(CPET==0) = nan;
[PETcy,cysPET] = wy2cy(CPET(:,2:end-1),CPET(:,1));
st.PET.mo_cy.CIMIS.data = PETcy;
st.PET.mo_cy.CIMIS.year = cysPET;

function st = get_pet_harg_mo(st,cpath)			% LOAD PET MONTHLY, HARGREAVES
Hpath = fullfile(cpath,'GRID_PRISM/GRID_PRISM_HPET/GRID_DATA_WY_MONTHLY_WEIGHTED_MEAN.txt');
HPET = dlmread(Hpath,'\t',2,0);
[PETcy,cysPET] = wy2cy(HPET(:,2:end-1),HPET(:,1));
st.PET.mo_cy.PRISM_Harg.data = PETcy;
st.PET.mo_cy.PRISM_Harg.year = cysPET;

function st = get_pet_hargm_mo(st,cpath)		% LOAD PET MO, HARGREAVES MODIFIED
HMpath = fullfile(cpath,'GRID_PRISM/GRID_PRISM_HMPET/GRID_DATA_WY_MONTHLY_WEIGHTED_MEAN.txt');
HMPET = dlmread(HMpath,'\t',2,0);
[PETcy,cysPET] = wy2cy(HMPET(:,2:end-1),HMPET(:,1));
st.PET.mo_cy.PRISM_HargM.data = PETcy;
st.PET.mo_cy.PRISM_HargM.year = cysPET;

function st = get_lc_igbp(st,cpath)				% LOAD LAND COVER, IGBP
Ipath = fullfile(cpath,'GRID_MODIS_CA/GRID_MODIS_CA_BESS_IGBP','GRID_DATA_WY_CODE_AREA_FRACTION.txt');
IGBP = dlmread(Ipath,'\t',2,0);
st.LC.cy.IGBP.data = IGBP(:,2:end);
st.LC.cy.IGBP.year = IGBP(:,1);

function st = get_model_params_trilin(st,cpath)	% LOAD MODEL PARAMS TRI-LIN
Mpath = fullfile(cpath,'DATA_PRODUCTS','ETo_aBb_stats.txt');
M = dlmread(Mpath,'\t',1,0); % [ETd, a, B, b]
st.MODELS.TriLin.params = M(1:4);
st.MODELS.TriLin.params_info = 'ETd(mm),a(mm),B(mm/mm),b(mm)';
st.MODELS.TriLin.errors = M(5:end);
st.MODELS.TriLin.errors_info = 'RMSofRmodel(mm),RMSofP-R/Prms(mm),R2ofRmodel(~),R2ofP-R/P(~),R2ofR/P';

function st = get_model_output_trilin(st,P,R,wb_type) % CALC MODEL OUTPUT
M = st.MODELS.TriLin.params;
[Rmodel,Rresid,CE_Rresids] = trilin_RvP_calc(M(2),M(4),M(3),P,R);
st.MODELS.TriLin.output.(wb_type).Robs = R;
st.MODELS.TriLin.output.(wb_type).Pobs = P;
st.MODELS.TriLin.output.(wb_type).Rmodel = Rmodel;
st.MODELS.TriLin.output.(wb_type).Rresid = Rresid;
st.MODELS.TriLin.output.(wb_type).CE_Rresids = CE_Rresids;
st.MODELS.TriLin.output.(wb_type).CE_Rresids_note = '{dry, mid, wet}';

function st = wswb_calc_wb_wy(st)				% CALCULATE WATER YEAR TOTALS
wy_types = fieldnames(st.WYday1);
Pd	= st.P.d_cy.PRISM.data;
Pcy = st.P.d_cy.PRISM.year;
Rd  = st.R.d_cy.USGS.data;
Rcy = st.R.d_cy.USGS.year;

MinDaysR = WB_PARAMS('MinDaysRwb');
MinDaysP = WB_PARAMS('MinDaysPwb');

for ii = 1:length(wy_types)
	wy_type = wy_types{ii};
	dowy1 = st.WYday1.(wy_type).docy;
	if isnan(dowy1)
		continue
	end
	[Ptot,Pwys] = wswb_calc_total_wy(Pd,Pcy,dowy1,MinDaysP);
	[Rtot,Rwys] = wswb_calc_total_wy(Rd,Rcy,dowy1,MinDaysR);
	
	st.WB.(wy_type).PRISM_USGS.P = Ptot;
	st.WB.(wy_type).PRISM_USGS.Pwys = Pwys;
	st.WB.(wy_type).PRISM_USGS.R = Rtot;
	st.WB.(wy_type).PRISM_USGS.Rwys = Rwys;
end

function st = calc_wytot(st)					% CALCULATE WY TOTALS FOR VARIOUS FLUXES
% st.(flux_type).(t_type).(flux_source).[data, year]
t_types = {'mo_cy','d_cy'};
wy_types = fieldnames(st.WYday1);
flux_types = WB_PARAMS('flux_types');
min_mo	= 12;							% min # months for valid WY total
min_days= WB_PARAMS('MinDaysGeneral');	% min # days for valid WY total
st.WYtot.done = true;

for ww = 1:length(wy_types)		% CYCLE THROUGH WATER YEAR TYPES
	wy_type = wy_types{ww};
	dowy1 = st.WYday1.(wy_type).docy;
	mowy1 = dowy1_2_mowy1(dowy1);
	if isnan(dowy1)
		continue
	end
	
	for ff = 1:length(flux_types)	% CYCLE THROUGH FLUX TYPES
		flux_type = flux_types{ff};
		if ~isfield(st,flux_type)
			continue
		end
		
		for tt = 1:length(t_types)	% CYCLE THROUGH TIME INTERVAL TYPES
			t_type = t_types{tt};
			if ~isfield(st.(flux_type),t_type)
				continue
			end
			
			flux_sources = WB_PARAMS(['sources_',flux_type]);
			for ss = 1:length(flux_sources)
				flux_source = flux_sources{ss};
				if ~isfield(st.(flux_type).(t_type),flux_source)
					continue
				end
				
				X = st.(flux_type).(t_type).(flux_source).data;
				Xcy = st.(flux_type).(t_type).(flux_source).year;
				
				% Convert to WY and calculate totals
				if strncmp(t_type,'m',1)		% MONTHLY
					[X,Xwy] = cy2wy_monthly(X,Xcy,mowy1);
					chkN = sum(~isnan(X),2)>=min_mo;
					
				elseif strncmp(t_type,'d',1)	% DAILY
					[X,Xwy] = cy2wy_daily(X,Xcy,dowy1);
					chkN = sum(~isnan(X),2)>=min_days;
				end
				X = X(chkN,:); Xwy = Xwy(chkN);
				Xtot = nansum(X,2);
				% save to structure
				st.WYtot.(flux_type).(flux_source).(t_type).(wy_type).data = Xtot;
				st.WYtot.(flux_type).(flux_source).(t_type).(wy_type).year = Xwy;
				xx = 1;
			end % ss
		end	% tt
	end % ff
end % ww
xx = 1;

function st = calc_Rb_recession_slope(st)		% CALCULATE Rb RECESSION SLOPE
dowy1_type = 'QuantMinRbDOY';
rb = st.Rb.d_cy.USGS.data;
wyday1 = st.WYday1.(dowy1_type).docy;

if isnan(wyday1)
	wyday1 = 274;	% revert to Oct 1 if no calculated DOWY1
	dowy1_type = 'Oct1';
end

[~,SlopeEachYr,st_uncert] = wswb_calc_mean_recession(rb,wyday1);

st.Rb.RecessionSlope.slope = SlopeEachYr;
st.Rb.RecessionSlope.units = 'dLn(Q)/dt';
st.Rb.RecessionSlope.stddev = st_uncert.EachYear.slope_std;
st.Rb.RecessionSlope.Nyears = st_uncert.EachYear.Nyears;
st.Rb.RecessionSlope.type = dowy1_type;
st.Rb.RecessionSlope.note = ['Calculated during the 30 days prior to DOWY1 type ',dowy1_type];

function st = get_Rb_dowy1(st)					% GET Rb ON DOWY1 EACH VALID YEAR
dowy1 = st.WYday1.QuantMinRbDOY.docy;
if isnan(dowy1)			% if DOWY1 not calculated due to poor baseflow data
	dowy1 = firstdayofmonth(10,2001);
end
Rb = st.Rb.d_cy.USGS.data;
cyear = st.Rb.d_cy.USGS.year;
lastyear = st.HYDROL_TIMELINE.LowFlow_undisturbed_last; % only years with valid Rb obs
chkyr = cyear <= lastyear;
Rb = Rb(chkyr,:);
cyear = cyear(chkyr);

Rb_dowy1 = Rb(:,dowy1);
st.Rb.Rb_dowy1.data = Rb_dowy1;
st.Rb.Rb_dowy1.cyear = cyear;

function st = calc_dS_yearly(st)				% ESTIMATE YEARLY dS FROM RECESSION SLOPE AND dQ
B	= st.Rb.RecessionSlope.slope;		% slope value (B = dLn(Q)/dt)
if isnan(B)
	st.dS.RecessionSlope.Oct1 = [];
	return
end

% neglect years with unnatural low flow
lastyear = st.HYDROL_TIMELINE.LowFlow_undisturbed_last;
cyear = st.Rb.d_cy.USGS.year;
yrchk = cyear <= lastyear;
cyear = cyear(yrchk);
Rb = st.Rb.d_cy.USGS.data;
Rb = Rb(yrchk,:);

% Oct 1
dowy1 = firstdayofmonth(10,2001);
[dS_Oct1,wyear] = wswb_calc_dS_recession(Rb,cyear,dowy1,B);
st.dS.RecessionSlope.wyear = wyear;

% Calculated DOWY1
dowy1 = st.WYday1.QuantMinRbDOY.docy;
if isnan(dowy1), st.dS.RecessionSlope.DOWY1 = []; return, end
dS_dowy1 = wswb_calc_dS_recession(Rb,cyear, dowy1,B);

st.dS.RecessionSlope.Oct1 = dS_Oct1;
st.dS.RecessionSlope.DOWY1 = dS_dowy1;

% cla
% plot(dS_dowy1,'b','Marker','o');
% plot(dS_Oct1,'r','Marker','o');
% st.ID
xx = 1;

function st = find_nested_ws(st)				% MAKE LIST OF WS NESTED IN PARENT
% load boundary data
mdir = WB_PARAMS('dir_master');
cdir = st.DIR;
stb = load(fullfile(mdir,cdir,'boundary','ST_BOUNDARY_DATA.mat'));
stb = stb.st_boundary;
bLat = stb.Lat_degN;
bLon = stb.Lon_degE;
sLat = st.METADATA.ws.GAGESII.BASINID.LAT_GAGE;
sLon = st.METADATA.ws.GAGESII.BASINID.LNG_GAGE;

d_nested_ws = wswb_search_nested_catchs2(bLat, bLon, sLat, sLon, cdir);

st.NestedWS.IDs = d_nested_ws;

function st = get_nested_scenes(st,st_master)	% NESTED SCENES
ID = st.ID;
ids_nested = st.NestedWS.IDs;
if isempty(ids_nested)	% skip if no nested WS
	return
end

data_types = {'R.mo_cy.USGS',...
	'P.mo_cy.PRISM',...
	'PET.mo_cy.CIMIS',...
	'PET.mo_cy.PRISM_Harg',...
	'PET.mo_cy.PRISM_HargM'};
data_type_chk = false(length(data_types),1);
for tt = 1:length(data_types)
	st_out = wswb_nested_scenes(st_master,ID,ids_nested,data_types{tt});
	if ~isempty(st_out)
		eval(['st.NestedWS.',data_types{tt},' = st_out;']);
		data_type_chk(tt,1) = true;
	end
end
if max(data_type_chk)>0
	st.NestedWS.data_types = data_types(data_type_chk);
else
	st.NestedWS.IDs = [];
end

function st = calc_fluxes_nonnested(st,st_master)	% CALC WY FLUXES UNNESTED
ids_nested = st.NestedWS.IDs;
if isempty(ids_nested)	% skip if no nested WS
	return
end
ID = st.ID;
stNested = st.NestedWS;
st_out = wswb_nested_fluxes(st_master,ID,stNested);

data_types = st.NestedWS.data_types;
nest_types = fieldnames(st_out);
% *** SORT OUT HOW TO ASSIGN UNNESTED DATA TO STRUCTURE WITH DYNAMIC VARS
for tt = 1:length(data_types)
	dtype = data_types{tt};
	for nn = 1:length(nest_types);
		ntype = nest_types{nn};
		dtype_short{tt,nn} = dtype(1:2);	% for later use
		eval(['D = st_out.',ntype,'.',dtype,'.data;'])
		eval(['Yrs = st_out.',ntype,'.',dtype,'.year;'])
		eval(['st.',dtype,'.UnNested.',ntype,'.data = D;'])
		eval(['st.',dtype,'.UnNested.',ntype,'.year = Yrs;'])
	end
end
% WY P and R TOTALS
% Make sure have both P and R
for nn = 1:length(nest_types)
	if max(strcmp(dtype_short(:,nn),'R.'))>0 && max(strcmp(dtype_short(:,nn),'P.'))>0
		ntype = nest_types{nn};
		lastWByr = st.HYDROL_TIMELINE.WB_undisturbed_last;
		% Runoff
		R	= st.R.mo_cy.USGS.UnNested.(ntype).data;
		cyR = st.R.mo_cy.USGS.UnNested.(ntype).year;
		chkwb = cyR <= lastWByr;
		R = R(chkwb,:);
		cyR = cyR(chkwb);
		Rwy = cy2wy_monthly(R,cyR,10);
		st.WB.Oct1.PRISM_USGS.UnNested.R.(ntype).data = sum(Rwy,2);
		st.WB.Oct1.PRISM_USGS.UnNested.R.(ntype).wyear = cyR(2:end);
		% Precip
		P	= st.P.mo_cy.PRISM.UnNested.LargestNested.data;
		cyP = st.P.mo_cy.PRISM.UnNested.LargestNested.year;
		Pwy = cy2wy_monthly(P,cyP,10);
		st.WB.Oct1.PRISM_USGS.UnNested.P.(ntype).data = sum(Pwy,2);
		st.WB.Oct1.PRISM_USGS.UnNested.P.(ntype).wyear = cyP(2:end);
	end
end
% PLOT (optional)
mdir = WB_PARAMS('dir_master');
if max(strcmp(dtype_short(:,nn),'R.'))>0 && max(strcmp(dtype_short(:,nn),'P.'))>0
	wb = st.WB.wy.PRISM_USGS.data;
	chkwb = st.WB.wy.PRISM_USGS.year <= lastWByr;
	wb = wb(chkwb,:);
	p = st.WB.Oct1.PRISM_USGS.UnNested.P.(ntype).data;
	py = st.WB.Oct1.PRISM_USGS.UnNested.P.(ntype).wyear;
	r = st.WB.Oct1.PRISM_USGS.UnNested.R.(ntype).data;
	ry = st.WB.Oct1.PRISM_USGS.UnNested.R.(ntype).wyear;
	[~,ip,ir] = intersect(py,ry);
	if isempty(ry(ir))
		return
	end
	
	hf = figure;
	hold on, box on
	scatter(p(ip),r(ir),'filled')
	scatter(wb(:,2),wb(:,3),'filled')
	legend('UnNested','Total','Location','NorthWest')
	frac = st.NestedWS.P.mo_cy.PRISM.LargestNested.area_fraction_of_parent;
	xlabel('P (mm)')
	ylabel('R (mm)')
	title([num2str(st.ID),', Area Frac Nested WS = ',num2str(frac)])
	pfig = fullfile(mdir,st.DIR,'DATA_PRODUCTS','UnNested_RvP');
	saveas(hf,[pfig,'.fig'])
	saveas(hf,[pfig,'.png'])
	close(hf);
end
xx = 1;

function st = get_p_vic_mo(st,cpath)			% IMPORT VIC MONTHLY
Ppath = fullfile(cpath,'GRID_VIC_CA','GRID_VIC_CA_PRECIP','GRID_DATA_WY_MONTHLY_WEIGHTED_MEAN.txt');
PVwy = dlmread(Ppath,'\t',2,0);
wyPV = PVwy(:,1);
PVwy = PVwy(:,2:end-1);

% save CY data to st_master
[PVcy,cysPV] = wy2cy(PVwy,wyPV,'month',10);
st.P.mo_cy.VIC.data = PVcy;
st.P.mo_cy.VIC.year = cysPV;
st.P.mo_cy.VIC.units = 'mm monthly';

function st = get_ghcn_nearby(st)				% NEARBY GHCN STATIONS
% first generate lists using wswb_dailyP_ghcn_proximity

% 3 GHCN stations closest to centroid
dir_ws = match_site_id_dir(st.ID);
dir_data = '/Users/tcmoran/Documents/ENV_DATA/Precipitation/GHCN';
path_list = fullfile(dir_data,'CatchDir_GHCNclosest3_List.csv');
fmat = '%s %s %s %s %f %f %f';
fid = fopen(path_list);
ce_ghcn = textscan(fid,fmat,'delimiter',',');
fclose(fid);
dir_ghcn = ce_ghcn{1};
ghcn_sta = [ce_ghcn{2:4}];
ghcn_dist= [ce_ghcn{5:7}];
idx_ws = find(strcmp(dir_ghcn,dir_ws));
ghcn_sta = ghcn_sta(idx_ws,:);
ghcn_dist= ghcn_dist(idx_ws,:);
st.METADATA.gage_data.ghcn.closest3.sites = ghcn_sta;
st.METADATA.gage_data.ghcn.closest3.dist = ghcn_dist;
st.METADATA.gage_data.ghcn.closest3.info = 'Three GHCND sites closest to watershed centroid';

% GHCN stations internal to watershed
path_list = fullfile(dir_data,'CatchDir_GHCN_Internal_List.csv');
ce_ghcn = csvimport(path_list);
dir_ghcn = ce_ghcn(:,1);
idx_ws = find(strcmp(dir_ghcn,dir_ws),1);
if isempty(idx_ws)
	st.METADATA.gage_data.ghcn.internal.sites = [];
	return
end
ce_ghcn = ce_ghcn(idx_ws,2:end);
st.METADATA.gage_data.ghcn.internal.sites = ce_ghcn(~strcmp(ce_ghcn,''));
st.METADATA.gage_data.ghcn.internal.info = 'All GHCND sites internal to watershed boundary';

% function st = calc_scaled_Pvic(st)
% 
% st = wswb_P_VIC_scaledby_PRISM(st);		% calculate totals
% Pvic = st.WYtot.P.VIC.mo_cy.Oct1.data;
% Pwys = st.WYtot.P.VIC.mo_cy.Oct1.year;
% pfit = st.P.mo_cy.VIC.WYtot_LinFit_vs_PRISM;
% PvicScaled = (Pvic-pfit(2))./pfit(1);
% st.WYtot.P.VIC_Scaled.mo_cy.Oct1.data = PvicScaled;
% st.WYtot.P.VIC_Scaled.mo_cy.Oct1.year = Pwys;
% st.WYtot.P.VIC_Scaled.mo_cy.Oct1.note = 'VIC P scaled by lin fit with yearly PRISM P';

function st = get_ghcn_best(st)
sg = wswb_annual_P_gage_find(st);
st.METADATA.gage_data.ghcn.BestLinFit = sg;


function st = next_function
