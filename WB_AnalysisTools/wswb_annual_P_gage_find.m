function s = wswb_annual_P_gage_find(st)

%% INITIALIZE
dir_ghcn_data = WB_PARAMS('dir_ghcn_data');
maxP = 5000;
mindays = 366-24;	% allow 2 missing days of data per month on average

%% PRISM
Pprism = st.P.mo_cy.PRISM.data;
Yprism = st.P.mo_cy.PRISM.year;
Nchk = sum(~isnan(Pprism),2)==12;
Pprism = sum(Pprism(Nchk,:),2);
Yprism = Yprism(Nchk);

%% GHCN CA GAGE LIST
gpath = '/Users/tcmoran/Documents/ENV_DATA/Precipitation/GHCN/GHCND_List_CA.csv';
fmt = '%s %f %f %f %s %s';
fid = fopen(gpath);
ghcn_ca = textscan(fid,fmt,'delimiter',',');
fclose(fid);
ghcn_id = ghcn_ca{1};
ghcn_LLH = [ghcn_ca{2:4}];
ghcn_loc = ghcn_ca{6};

%% MAKE SURE FILES MATCH LIST
for ii = 1:length(ghcn_id), fnames_g{ii,1} = [ghcn_id{ii},'.mat']; end
fnames_mat = get_file_names2(dir_ghcn_data,'.mat');
[fnames_g,~,gidx] = intersect(fnames_mat,fnames_g);
ghcn_LLH = ghcn_LLH(gidx,:);
ghcn_loc = ghcn_loc(gidx,:);
tic
for gg = 1:length(fnames_g)
	fname = fnames_g{gg};
	load(fullfile(dir_ghcn_data,fname));
	% gage P data
	p = double(st_ghcnd.data.prcp.data);
	p(p==-9999) = nan;
	p = p/10;				% **** Units seem to be mm*10? ****
	yrs = double(st_ghcnd.data.prcp.year);
	
	% check for sufficient number of days and gage meas reality check
	Nchk = sum(~isnan(p),2) > mindays;
	p = p(Nchk,:);
	yrs = yrs(Nchk);
	ptot = nansum(p,2);
	Pchk = ptot < maxP;		% neglect unrealistically large gage values
	ptot = ptot(Pchk);
	yrs = yrs(Pchk);
	
	% Find years common to PRISM data
	pcommon = wswb_common_years({Pprism,ptot},{Yprism,yrs});
	
	% linear fit of PRISM vs Gage
	[pfit,S] = polyfit(pcommon{2},pcommon{1},1);
	[Pval,Pdelta] = polyval(pfit,pcommon{2},S);
	r2 = rsquare(pcommon{1},Pval,1);
	rmse = sqrt(mean((Pval-pcommon{1}).^2));
	
	R2(gg,1) = r2;
	RMSE(gg,1) = rmse;
	PFIT(gg,:) = pfit;
	dt = toc;
	% 	progress_time(gg,length(fnames_g),dt,'sec',true)
end

%% CHOOSE BEST FIT: Min RMSE of Max R2
% indices of max R2 values rounded to 2 decimal places
idxR2max = find(round(R2*100)/100 == max(round(R2*100)/100));
[~,idxRMSEmin] = min(RMSE(idxR2max));
idx  = idxR2max(idxRMSEmin);

s.linfit.r2 = R2(idx);
s.linfit.rmse = RMSE(idx);
s.linfit.slope_intercept = PFIT(idx,:);
s.linfit.units = 'mm/yr';
s.linfit.info = 'P(PRISM) vs P(gage)';
s.ghcn_site.id = ghcn_id{idx};
s.ghcn_site.LatLonAlt = ghcn_LLH(idx,:);
s.ghcn_site.name = ghcn_loc{idx};
s.ghcn_site.LatLonAlt_units = 'degN degE m';
s.info = 'best linear fit of yearly lumped PRISM P with GHCND P';

%% DISTANCE OF GHCN FROM WATERSHED CENTROID and INBOUNDARY CHECK
cdir = st.DIR;
mdir = WB_PARAMS('dir_master');
stb = load(fullfile(mdir,cdir,'boundary','ST_BOUNDARY_DATA.mat'));
stb = stb.st_boundary;
bLatLon = [stb.Lat_degN;stb.Lon_degE]'; % boundary for this catchment
% filter boundary polygons to less than 1000 points
while length(bLatLon) > 1000
	bLatLon = bLatLon(1:2:end,:);
end
sLatLon = [stb.ref_point.Latitude,stb.ref_point.Longitude]; % site Lat/Lon for this catchment
% centroid is better for checking interal to boundary because some site coords have errors
geom = polygeom(bLatLon(:,2),bLatLon(:,1));
cLatLon = [geom(3),geom(2)]; % centroid of this catchment
AreaWS = geom(1);

INchkSite = inpolygon(ghcn_LLH(idx,2), ghcn_LLH(idx,1), bLatLon(:,2), bLatLon(:,1));
DistBdry = distance(bLatLon(:,1),bLatLon(:,2),...
					ghcn_LLH(idx,1)*ones(length(bLatLon),1),ghcn_LLH(idx,2)*ones(length(bLatLon),1),...
					referenceEllipsoid('grs80','km'));
DistBdryMin = round(min(DistBdry));

s.ghcn_site.in_boundary = INchkSite;
s.ghcn_site.dist_from_boundary_km = DistBdryMin;
xx = 1;