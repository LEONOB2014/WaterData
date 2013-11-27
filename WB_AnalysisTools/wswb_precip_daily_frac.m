function wswb_precip_daily_frac

% WSWB_PRECIP_DAILY_FRAC calculates the fraction of monthly precip that
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
fdir = '/Users/tcmoran/Documents/ENV_DATA/Precipitation/GHCN';
fname = 'CatchDir_GHCNclosest3_List.csv';
fpath = fullfile(fdir,fname);
fid = fopen(fpath);
CGlist = textscan(fid,'%s %s %s %s %s %s %s','Delimiter',',');
fclose(fid);
CGlist = [CGlist{1:7}];

%% CYCLE THROUGH LIST
% Pmindays = 330;         % min # valid precip days per year
% PfracTotThresh = 0.3;   % fraction of total yearly precip
nc = length(CGlist);
for cc = 1:nc
	%% CYCLE THROUGH 3 STATIONS FOR EACH WATERSHED
	for ii = 1:3
		% Load daily P data from GHCN
		gname = [CGlist{cc,ii+1},'.mat'];
		gdist(ii) = str2double(CGlist{cc,ii+4});			% dist of ghcn sta from ws centroid
		gpath = fullfile(gdir,gname);
		load(gpath)
		% Precip
		P = st_ghcnd.data.prcp.data;
		P = double(P); P(P==-9999) = nan;
		Pyr{ii} = double(st_ghcnd.data.prcp.year);
		% Tmax
		T = st_ghcnd.data.tmax.data;
		T = double(T); T(T==-9999) = nan;
		Tyr{ii} = double(st_ghcnd.data.tmax.year);
		% Tmin
		t = st_ghcnd.data.tmin.data;
		t = double(t); t(t==-9999) = nan;
		tyr{ii} = double(st_ghcnd.data.tmin.year);
		
		% NOTE: P and Temp data may have different intervals, so need to
		% process each separately
		PMO{ii} = calc_Pdaily_frac(P,Pyr{ii});
		TMO{ii} = calc_Tdaily_vary(T,Tyr{ii});
		tMO{ii} = calc_Tdaily_vary(t,tyr{ii});
	end
	
	%% MAKE SINGLE MONTHLY CELL ARRAY COMBINING ALL STATIONS
	[PMO,PYR,NPreplace] = combine_multiple_month_arrays(PMO,Pyr);
	[TMO,TYR,NTreplace] = combine_multiple_month_arrays(TMO,Tyr);
	[tMO,tYR,Ntreplace] = combine_multiple_month_arrays(tMO,tyr);
	
	%% Make Daily P and T Structure
	st.P.cy = PYR;
	st.P.monthly_frac = PMO;
	st.P.note = 'Pday/Pmonth';
	st.P.months_filled_nearby_stations = NPreplace;
	st.Tmax.monthly_frac_K = TMO;
	st.Tmax.cy = TYR;
	st.Tmax.note = 'Tday(K)/Tmonth_avg(K)';
	st.Tmax.months_filled_nearby_stations = NTreplace;
	st.Tmin.monthly_frac_K = tMO;
	st.Tmin.cy = tYR;
	st.Tmin.note = 'Tday(K)/Tmonth_avg(K)';
	st.Tmin.months_filled_nearby_stations = Ntreplace;
	st.GHCN_site = st_ghcnd.meta;
	st.GHCN_site.GHCNid = st_ghcnd.staid;
	st.GHCN_site.dist2ws_centroid_km = gdist;
	
	st_PTdaily = st;
	
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
		% Tday = nanzscore(Tmo);
		% Convert to Kelvin, calculate daily as fractional deviation from mean
		TdayK = (Tmo./10)+273.15;
		TMO{yy,mm} = TdayK./nanmean(TdayK(:));
		TDAY(yy,dom1(mm):domL(mm)) = TdayK;	% don't save, just to check results
	end
end
xx=1;

%% COMBINE MULTIPLE MONTH ARRAYS
function [MO,MOyrs,Nreplace] = combine_multiple_month_arrays(MOin,MOyr)
nsites = length(MOyr);
% find min/max years
for ii = 1:nsites
	minyr(ii) = nanmin(MOyr{ii});
	maxyr(ii) = nanmax(MOyr{ii});
end
minyr = min(minyr);
maxyr = max(maxyr);
MOyrs = (minyr:maxyr)';

% Pre-allocate MO with NaNs
MO = cell(length(MOyrs),12);
for yy = 1:length(MOyrs)
	for mm = 1:12
		MO{yy,mm} = nan(1,daysinmonth(mm,MOyrs(yy)));
	end
end

% first fill MO with data from closest GHCN station
[~,idx] = ismember(MOyr{1},MOyrs);
idx = idx(idx>0);
MO(idx,:) = MOin{1};

% Then replace any empty months (NaNs) with data from next closest stations
Nreplace = 0;
for ii = 2:nsites
	yrii = MOyr{ii};
	MOii = MOin{ii};
	for yy = 1:length(yrii)
		yidx = find(MOyrs==yrii(yy));
		for mm = 1:12
			if sum(isnan(MO{yidx,mm}))>2 && sum(isnan(MOii{yy,mm}))<3
				MO{yidx,mm} = MOii{yy,mm};
				Nreplace = Nreplace+1;
			end
		end
	end
end