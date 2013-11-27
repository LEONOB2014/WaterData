function [d_in_catch, d_near_catch] = search_coords_inbound2(LatLon,this_catch,flist,mdir)

% SEARCH_COORDS_INBOUND2(LatLon,flist,mdir) searches all catchments listed
% in file FLIST to determine if the coords LatLon are internal to any of
% the catchment boundaries.
%
% INPUTS
% LatLon = [LatN, LonE] decimal coordinates
% this_catch = site id of catchment being checked, used to keep from
%                       counting a site's own catchment
% flist      = file name of text list of catchments to check
% mdir    = abs path to master directory containing HUC and Catchment directories
%
% OUTPUTS
% d_in_catch = cell list of catchments that contain the coordinate
% d_near_catch = cell list of catchments near the coordinate
%
% TC Moran UC Berkeley 2012

%% INITIALIZE and DEFAULTS
if nargin < 4
    mdir = '/Users/tcmoran/Desktop/Catchment Analysis 2011/AA_CA_Catchments_Master/GAGESII_CATCHMENTS_CA';
end
if nargin < 3
    flist = 'FILTERED_CATCHMENTS_219.txt';
end
if nargin < 2
    this_catch = []; % empty matrix to ignore this_catch
end

dir_orig = cd(mdir);
[ce_list_rel, ce_list_abs] = import_catchment_list(flist,mdir);
ncatch = length(ce_list_rel);
Lat = LatLon(1); Lon = LatLon(2);

dLL = 0.2; % distance from site for bound to be considered 'near' (deg)


%% CYCLE THROUGH CATCHMENTS TO CHECK IF COORDS IN BOUNDARY POLYGON
ii = 1; jj = 1;
d_in_catch = []; d_near_catch = [];
for cc = 1:ncatch
    dir_this = ce_list_abs{cc};
    if ~isempty(strfind(dir_this,num2str(this_catch)))
        continue
    end % skip own directory
    
    dir_last = cd(dir_this);
    if ~isdir('boundary'); continue; end
    % move to boundary directory if it's there
    cd('boundary')
    stb = load('ST_BOUNDARY_DATA.mat');
    stb = stb.st_boundary;
    bLat = stb.Lat_degN;
    bLon = stb.Lon_degE;
    INchk = inpolygon(Lon, Lat, bLon, bLat);
    
    % Also check if boundary is near to sit
    if ~INchk
        NRchk = false;
        dLat = bLat - Lat;
        dLon = bLon - Lon;
        dist2bound = sqrt(dLat.^2 + dLon.^2);
        mindist = min(abs(dist2bound));
        if mindist < dLL, NRchk = true; end
    end
    
    % make a list of catchments that contain this point
    if NRchk & ~INchk
        d_near_catch(jj) = cc;
%         zdata = zeros(length(bLat),1);
%         patch(bLon,bLat,zdata,'EdgeColor','m','FaceColor','none')
%         plot(Lon,Lat,'xr')
        jj = jj+1;
    end
    if INchk
        d_in_catch(ii) = cc;
%         zdata = 100*ones(length(bLat),1);
%         patch(bLon,bLat,1,'EdgeColor','b','FaceColor','none')
%         plot(Lon,Lat,'xr')
        ii = ii+1;
    end
%     catchs_to_go = ncatch - cc
end
cd(dir_orig)

