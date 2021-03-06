function wswb_dailyP_ghcn_proximity

% WSWB_DAILYP_GHCN_PROXIMITY finds the 3 closest GHCN daily precipitation
% stations to water balance watersheds

%% IMPORT LIST OF CATCHMENT DIRS
fname_list = WB_PARAMS('wslist_ca219');
dir_root = WB_PARAMS('dir_master');
fid = fopen(fullfile(dir_root,fname_list));
Clist = textscan(fid,'%s','HeaderLines',1);
fclose(fid);
Clist = Clist{1};

%% IMPORT GHCN STA COORDS
dir_list = '/Users/tcmoran/Documents/ENV_DATA/Precipitation/GHCN';
fname_list = 'GHCND_List_CA.csv';
path_list = fullfile(dir_list, fname_list);
fmat = '%s %f %f %f %s %s';
fid = fopen(path_list);
CElist = textscan(fid,fmat,'delimiter',',');
fclose(fid);
Gid = CElist{1};

%% EXCLUDE GHCN STATIONS NOT PRE-PROCESSED
dir_gmat = '/Users/tcmoran/Desktop/IMWW/IMWW_DATA/CLIMATE_GHCND/IMWW_DATA/ghcnd_matlab';
gmat_fnames = get_file_names2(dir_gmat,'.mat');
gmat_fnames = cell2mat(gmat_fnames');
gmat_fnames = gmat_fnames(:,1:11);
gmat_fnames = mat2cell(gmat_fnames,ones(size(gmat_fnames,1),1) );
gchk = ismember(Gid,gmat_fnames);

% GHCN: ID, LAT, LON, Name
Gid = CElist{1}(gchk);
Lat = CElist{2}(gchk);
Lon = CElist{3}(gchk);
Name = CElist{6}(gchk);

%% FIND CLOSEST GHCN STA FOR EACH WS
Nc = length(Clist);
DistSta = zeros(Nc,3); IDXcent = nan(Nc,3);
RefEllipse = referenceEllipsoid('grs80');
NumIn = zeros(Nc,1);
for cc = 1:Nc		% CYCLE THROUGH WS
	
	ffbound = fullfile(dir_root,Clist{cc},'boundary','ST_BOUNDARY_DATA');
	load(ffbound)
	blat = st_boundary.Lat_degN;		% WS boundary polygon
	blon = st_boundary.Lon_degE;
	geom = polygeom(blon, blat);
	ctrLon = geom(2); ctrLat = geom(3); % WS Centroid
	
	% CHOOSE 3 CLOSEST STATIONS TO WS CENTROID
	Dcent = zeros(length(Lat),1);
	idx_in = [];
	for dd = 1:length(Lat)
		Dcent(dd) = distance(Lat(dd),Lon(dd),ctrLat,ctrLon,RefEllipse);
		[INchk,ONchk] = inpolygon(Lon(dd),Lat(dd),blon,blat);
		INchk = logical(max(INchk,ONchk));
		if INchk
			idx_in = [idx_in,dd];
		end
	end
	[Dsort,Didx] = sort(Dcent);
	DistSta(cc,1:3) = Dsort(1:3);
	IDXcent(cc,1:3)	= Didx(1:3);
	IDXin{cc,1} = idx_in;
	NumIn(cc) = length(idx_in);
	
	display([num2str(100*cc/Nc),'% done'])
	
end

%% SAVE TEXT FILE WITH CATCHMENT & GHCN STA LISTS
%  3 closest stations
DISTSTA = mat2cell(DistSta/1000,ones(size(DistSta,1),1),ones(size(DistSta,2),1));	% convert dist to km
GHCN_List = cellstr(Gid(IDXcent));
CatchDir_GHCN_List = [Clist, GHCN_List, DISTSTA];
fname_cglist = 'CatchDir_GHCNclosest3_List.csv';
path_cglist = fullfile(dir_list,fname_cglist);
cell2csv(path_cglist,CatchDir_GHCN_List,',');

% Stations internal to WS
idx = find(NumIn>0);
ceIN = cell(length(idx),max(NumIn));
for ii = 1:length(idx)
	for ss = 1:length(IDXin{idx(ii)})
		ceIN{ii,ss} = Gid{IDXin{idx(ii)}(ss)};
	end
end
CatchDir_StaIn = [(Clist(idx)),ceIN];
fname_cglist_in = 'CatchDir_GHCN_Internal_List.csv';
path_cglist = fullfile(dir_list,fname_cglist_in);
cell2csv(path_cglist,CatchDir_StaIn,',');


