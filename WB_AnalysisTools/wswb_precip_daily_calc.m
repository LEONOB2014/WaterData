function wswb_precip_daily_calc

% WSWB_PRECIP_DAILY_CALC calculates the fraction of monthly precip that
% occurs on each day of the month and saves this information in a file
% Daily P data is from GHCN weather station closest to each watershed

%% FIRST RUN SCRIPT TO ASSOCIATE GCHN STATIONS WITH EACH WS
% catchment_ghcn_check_script

%% INTIALIZE
dir_master = '/Users/tcmoran/Desktop/Catchment Analysis 2011/AA_CA_Catchments_Master/GAGESII_CATCHMENTS_CA/GAGESII_CATCHMENTS_219';
dir_dailyPT = 'GAGE_PRECIP_TEMP_GHCN';
fname_monthly_frac = 'GHCN_PT_Daily.mat';

%% LOAD CATCHMENT / GHCN ID LIST
gdir = '/Users/tcmoran/Desktop/IMWW/IMWW_DATA/CLIMATE_GHCND/IMWW_DATA/ghcnd_matlab';
fdir = '/Users/tcmoran/Desktop/2012 Catchment Analysis/GHCN Weather';
fname = 'CatchDir_GHCNclosest_List.csv';
fpath = fullfile(fdir,fname);
fid = fopen(fpath);
CGlist = textscan(fid,'%s %s %s','Delimiter',',');
fclose(fid);
CGlist = [CGlist{1:3}];

%% CYCLE THROUGH LIST
% Pmindays = 330;         % min # valid precip days per year
% PfracTotThresh = 0.3;   % fraction of total yearly precip
nc = length(CGlist);
for cc = 1:nc
	% Load daily P data from GHCN
	gname = [CGlist{cc,2},'.mat'];
	gpath = fullfile(gdir,gname);
	load(gpath)
	% Precip
	P = st_ghcnd.data.prcp.data;
	P = double(P); P(P==-9999) = nan;
	Pyr = double(st_ghcnd.data.prcp.year);
	% Tmax
	T = st_ghcnd.data.tmax.data;
	T = double(T); T(T==-9999) = nan;
	Tyr = double(st_ghcnd.data.tmax.year);
	% Tmin
	t = st_ghcnd.data.tmin.data;
	t = double(t); t(t==-9999) = nan;
	tyr = double(st_ghcnd.data.tmin.year);
	
	% NOTE: P and Temp data may have different intervals, so need to
	% process each separately
	
	PMO = calc_Pdaily_frac(P,Pyr);
	TMO = calc_Tdaily_vary(T,Tyr);
	tMO = calc_Tdaily_vary(t,tyr);

	
	%% Make Daily P and T Structure
	st_PTdaily.P.cy = Pyr;
	st_PTdaily.P.monthly_frac = PMO;
	st_PTdaily.Tmax.monthly_zscore = TMO;
	st_PTdaily.Tmax.cy = Tyr;
	st_PTdaily.Tmin.monthly_zscore = tMO;
	st_PTdaily.Tmin.cy = tyr;
	st_PTdaily.GHCN_site = st_ghcnd.meta;
	st_PTdaily.GHCN_site.GHCNid = st_ghcnd.staid;
	st_PTdaily.GHCN_site.dist2catch_km = str2num(CGlist{cc,3});
	
	
	%% SAVE STRUCTURE
	dir_ws = CGlist{cc,1};
	dir_P = fullfile(dir_master,dir_ws,dir_dailyPT);
	if ~isdir(dir_P), mkdir(dir_P), end
	% Save GHCN data structure
	save(fullfile(dir_P,gname),'st_ghcnd')
	% Save Monthly Fractions Cell
	save(fullfile(dir_P,fname_monthly_frac),'st_PTdaily')
	
	display([num2str(100*cc/nc),'% done'])
end

%% PRECIP 
function PMO = calc_Pdaily_frac(P,Pyr)
PDAY = nan(size(P));
for yy = 1:length(Pyr)
	dom1 = firstdayofmonth(1:12,Pyr(yy));
	domL = [dom1(2:end)-1,366];
	
	for mm = 1:12
		Pmo = P(yy,dom1(mm):domL(mm));
		% Allow one day of missing data per month
		% (*** EVENTUALLY FILL GAPS?***)
		if sum(isnan(Pmo))>1
			PMO{yy,mm} = nan(size(Pmo));
			continue
		end
		% FRACTION OF MONTHLY P FOR EACH DAY
		if nansum(Pmo)>0
			Pday = Pmo./nansum(Pmo);
		else
			Pday = Pmo;
		end
		PMO{yy,mm} = Pday;
		PDAY(yy,dom1(mm):domL(mm)) = Pday;	% don't save, just to check results
	end
end
xx = 1;		% debug line


%% TEMPERATURE
function TMO = calc_Tdaily_vary(T,Tyr)
TDAY = nan(size(T));
for yy = 1:length(Tyr)
	dom1 = firstdayofmonth(1:12,Tyr(yy));
	domL = [dom1(2:end)-1,366];
	% Cycle through years
	for mm = 1:12
		Tmo = T(yy,dom1(mm):domL(mm));
		% Allow three days of missing data per month, ~10% of month
		% (*** EVENTUALLY FILL GAPS?***)
		if sum(isnan(Tmo))>3
			TMO{yy,mm} = nan(size(Tmo));
			continue
		end
		% Zscore of T --> avoids problems with small temp values
		Tday = nanzscore(Tmo);
		TMO{yy,mm} = Tday;
		TDAY(yy,dom1(mm):domL(mm)) = Tday;	% don't save, just to check results
	end
end
xx = 1;		% debug line
