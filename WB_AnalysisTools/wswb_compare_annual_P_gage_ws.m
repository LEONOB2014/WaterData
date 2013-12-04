function wswb_compare_annual_P_gage_ws(st_master,id)


%% INITIALIZE
if nargin < 2
	id = 11464500;
end
mindays = 335;

dir_ws = match_site_id_dir(id);


%% IMPORT LIST OF GHCN STATIONS NEAR WATERSHED
path_list = '/Users/tcmoran/Documents/ENV_DATA/Precipitation/GHCN/CatchDir_GHCNclosest3_List.csv';
fmat = '%s %s %s %s %f %f %f';
fid = fopen(path_list);
ce_ghcn = textscan(fid,fmat,'delimiter',',');
dir_ghcn = ce_ghcn{1};
ghcn_sta = [ce_ghcn{2:4}];
ghcn_dist= [ce_ghcn{5:7}];
idx_ws = find(strcmp(dir_ghcn,dir_ws));
ghcn_sta = ghcn_sta(idx_ws,:);
ghcn_dist= ghcn_dist(idx_ws,:);


%% LUMPED AVERAGE PRECIP
idx = find([st_master(:).ID]==id);
stws = st_master(idx);

% PRISM
Pprism = stws.P.mo_cy.PRISM.data;
Yprism = stws.P.mo_cy.PRISM.year;
Nchk = sum(~isnan(Pprism),2)==12;
Pprism = sum(Pprism(Nchk,:),2);
Yprism = Yprism(Nchk);

% dir_master = WB_PARAMS('dir_master');
% dir_ws = fullfile(dir_master,match_site_id_dir(id));
% dir_ghcn = fullfile(dir_ws,'GAGE_PRECIP_TEMP_GHCN');
% fnames = get_file_names2(dir_ghcn,'US');

%% LOAD GHCND DATA
for ff = 1:length(fnames)
	load(fullfile(dir_ghcn,fnames{ff}));
	stg(ff) = st_ghcnd;
	
	p = double(st_ghcnd.data.prcp.data);
	p(p==-9999) = nan;
	p = p/10;				% **** Units seem to be mm*10? ****
	yrs = double(st_ghcnd.data.prcp.year);

	Nchk = sum(~isnan(p),2) > mindays;
	p = p(Nchk,:);
	Ptot{ff} = nansum(p,2);
	Yrs{ff} = yrs(Nchk);
	[Pcommon{ff},Ycommon{ff}] = wswb_common_years({Pprism,Ptot{ff}},{Yprism,Yrs{ff}});
	xx = 1;
end

xx = 1;