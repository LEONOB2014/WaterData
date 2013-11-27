function [ce_nested_catchs,ce_nearby_catchs] = wswb_search_nested_catchs2(BLat, BLon, SLat, SLon, this_catch, mdir, flist)

% SEARCH_NESTED_CATCHS2(bLat,bLon,mdir,flist) searches the catchment list
% 'flist' within the master directory 'mdir' for catchments that are nested
% within the boundary vectors 'BLat' and 'BLon'. 'this_catch' indicates the
% current catchment to exclude from nested list.
%
% INPUTS
% BLat, BLon = boundary vectors for parent catchment to check
% SLat, SLon = gage site location for parent catchment 
% this_catch = path to parent catchment
% mdir = master directory that contains catchment directories
% flist = list of catchments to check
%
%
% TC Moran UC Berkeley 2012

%% INITIALIZE and DEFAULTS
if nargin < 6
    mdir = WB_PARAMS('dir_master');
end
if nargin < 7
    flist = WB_PARAMS('wslist_ca219');
end
if nargin < 4
    this_catch = []; % empty matrix to ignore this_catch
end

% dir_orig = cd(mdir);
[ce_list_rel, ce_list_abs] = import_catchment_list(fullfile(mdir,flist),mdir);
Nc = length(ce_list_rel);

dLL = 0.2; % distance from site for bound to be considered 'near' (deg)

% cla
% patch(BLon,BLat,'k','EdgeColor','k','FaceColor','none')
% plot(SLon,SLat,'xr')
%% CYCLE THROUGH CATCHMENTS TO CHECK IF COORDS IN BOUNDARY POLYGON
ii = 1; jj = 1;
ce_nested_catchs = []; ce_nearby_catchs = [];
for cc = 1:Nc
    dir_this = ce_list_abs{cc};
    if ~isempty(strfind(dir_this,num2str(this_catch)))
        continue
    end % skip self directory
    
    stb = load(fullfile(dir_this,'boundary','ST_BOUNDARY_DATA.mat'));
    stb = stb.st_boundary;
    bLat = stb.Lat_degN; % boundary for this catchment
    bLon = stb.Lon_degE;
	% filter boundary polygons to less than 1000 points
	while length(bLat) > 1000
		bLat = bLat(1:2:end);
		bLon = bLon(1:2:end);
	end
	
    sLat = stb.ref_point.Latitude; % site Lat/Lon for this catchment
    sLon = stb.ref_point.Longitude;
    geom = polygeom(bLon,bLat);
    cLon = geom(2); cLat = geom(3); % centroid of this catchment
    
    INchk = inpolygon(sLon, sLat, BLon, BLat);
    
    % Also check if centroid of catchment is near boundary 
    if ~INchk
        NRchk = false;
        % make sure parent catch isn't nested in this catchment
        INchk2 = inpolygon(SLon,SLat,bLon,bLat);
        if INchk2, 
            continue,
        end
        dLat = BLat - cLat;
        dLon = BLon - cLon;
        dist2bound = sqrt(dLat.^2 + dLon.^2);
        mindist = min(abs(dist2bound));
        if mindist < dLL, NRchk = true; end
    end
    
   
    % make a list of catchments that contain this point
	dir_ws = ce_list_rel{cc};
	idx = strfind(dir_ws,'Site');
	ID = str2num(dir_ws(idx+4:idx+11));
    if NRchk & ~INchk
		ce_nearby_catchs(jj,1) = ID;
        jj = jj+1;
    end
    if INchk
        ce_nested_catchs(ii,1) = ID;
        ii = ii+1;
	end
% 	if mod(cc,10)==0, display([num2str(100*cc/Nc),' % done nested ws check']), end
end
xx = 1;
