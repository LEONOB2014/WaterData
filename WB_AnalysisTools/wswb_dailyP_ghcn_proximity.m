function wswb_dailyP_ghcn_proximity

% WSWB_DAILYP_GHCN_PROXIMITY finds the 3 closest GHCN daily precipitation
% stations to water balance watersheds

%% IMPORT LIST OF CATCHMENT DIRS
fname_list = 'FILTERED_CATCHMENTS_219.txt';
dir_root = '/Users/tcmoran/Desktop/Catchment Analysis 2011/AA_CA_Catchments_Master/GAGESII_CATCHMENTS_CA/GAGESII_CATCHMENTS_219';
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

%% FIND CLOSEST GHCN STA FOR EACH CATCHMENT
Nc = length(Clist);
DistSta = zeros(Nc,3); IDX = nan(Nc,3);
RefEllipse = referenceEllipsoid('grs80');
for cc = 1:Nc
%     jj = 1;
	display([num2str(100*cc/Nc),'% done'])
    ffbound = fullfile(dir_root,Clist{cc},'boundary','ST_BOUNDARY_DATA');
    load(ffbound)
    blat = st_boundary.Lat_degN;
    blon = st_boundary.Lon_degE;

    % if no ghcn station in catchment then look for closest to centroid
    geom = polygeom(blon, blat);
    ctrLon = geom(2); ctrLat = geom(3); % coords of centroid
    % calculate distance from each ghcn sta, choose closest
	D = zeros(length(Lat),1);
	for dd = 1:length(Lat)
        D(dd) = distance(Lat(dd),Lon(dd),ctrLat,ctrLon,RefEllipse);
	end
	[Dsort,Didx] = sort(D);
	DistSta(cc,1:3) = Dsort(1:3);
	IDX(cc,1:3)	= Didx(1:3);
     
end

%% SAVE TEXT FILE WITH CATCHMENT & GHCN STA LISTS
%% *** fix to save 3 closest stations
DISTSTA = mat2cell(DistSta/1000,ones(size(DistSta,1),1),ones(size(DistSta,2),1));	% convert dist to km
GHCN_List = cellstr(Gid(IDX));
CatchDir_GHCN_List = [Clist, GHCN_List, DISTSTA];
fmat = '%s %s %1.0f %s %1.0f %s %1.0f';
fname_cglist = 'CatchDir_GHCNclosest3_List.csv';
path_cglist = fullfile(dir_list,fname_cglist);
cell2csv(path_cglist,CatchDir_GHCN_List,',');

