function wswb_precip_daily_PRISM

% WSWB_PRECIP_DAILY_PRISM estimates daily P from monthly PRISM data 
% using data from nearby GHCN gage
%
% TC Moran 2013

%% INTIALIZE
mdir = WB_PARAMS('dir_master');

% WS list
flist = 'FILTERED_CATCHMENTS_219.txt';
plist = fullfile(mdir,flist);
[~,ce_list_abs] = import_catchment_list(plist,mdir);

% Daily P data
dir_dailyPT = 'GAGE_PRECIP_TEMP_GHCN';
fname_monthly_frac = 'GHCN_PT_Daily.mat';

% Monthly PRISM P data
dir_prismP = 'GRID_PRISM/GRID_PRISM_PRECIP';
fname_prismP = 'GRID_DATA_WY_MONTHLY_WEIGHTED_MEAN.txt';

%% CYCLE THROUGH WS LIST
nc = length(ce_list_abs);
for cc = 1:nc
	cdir= ce_list_abs{cc};
	% load daily P data (daily fraction of monthly total)
	load(fullfile(cdir,dir_dailyPT,fname_monthly_frac))
	Pd_cy = st_PTdaily.P.cy;
	Pd_frac = st_PTdaily.P.monthly_frac;
	
	% Convert daily fractions from CY to WY
	[Pd_frac,Pd_wy] = cy2wy_monthly(Pd_frac,Pd_cy);
	
	% load PRISM monthly data
	Pmo = dlmread(fullfile(cdir,dir_prismP,fname_prismP),'\t',2,0);
	Pm_wy = Pmo(:,1);
	Pmo = Pmo(:,2:end-1);
	
	%%
	[~,idx_mo]= ismember(Pd_wy,Pm_wy);
	idx_mo = idx_mo(idx_mo>0);
	Pmo = Pmo(idx_mo,:); Pm_wy = Pm_wy(idx_mo);
	[~,idx_d] = ismember(Pm_wy,Pd_wy);
	idx_d = idx_d(idx_d>0);
	Pd_frac = Pd_frac(idx_d,:); Pd_wy = Pd_wy(idx_d);
	if Pd_wy ~= Pm_wy
		display('oops, why dont years match? press any key to continue')
		pause
	end
	
	%% CYCLE THROUGH YEARS and MONTHS
	Pday_mo = cell(size(Pmo));
	ny = length(Pd_wy);
	Pday_wy = nan(ny,366);
	mo = [10:12,1:9];
	daysmo = [daysinmonth(10:12),daysinmonth(1:9)];
	
	for yy = 1:ny
		for mm = 1:12
			pday_mo = Pd_frac{yy,mm}*Pmo(yy,mm);
			% Pday_mo{yy,mm} = pday_mo;
			day1 = firstdayofmonth(mo(mm),Pd_wy(yy)-1,10);
			ndays = daysmo(mm);
			if mm == 5 && isleapyear(Pd_wy(yy)), 
				ndays = ndays+1;
			end
			Pday_wy(yy,day1:day1+ndays-1) = pday_mo(1:ndays);
		end
	end
	
	st_PTdaily.P.wy_daily_mm = Pday_wy;
	st_PTdaily.P.wy = Pd_wy;
	
	save(fullfile(cdir,dir_dailyPT,fname_monthly_frac),'st_PTdaily')
	display([num2str(100*cc/nc),'% done'])
end
xx = 1; % debug