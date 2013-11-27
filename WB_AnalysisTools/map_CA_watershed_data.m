function hf = map_CA_watershed_data(D,DIR_WS,ID)

% MAP_CA_WATERSHED_DATA(D,DIR_WS,ID) plots watersheds specified by DIR_WS
% and ID on a map of California with colormap color specified by D
%
% INPUTS
% D		= scalar data for each watershed, same scale for all [Nws x 1]
% DIR_WS= list of watershed directory paths relative to master directory 
% ID	= vector of watershed IDs
%
% OUTPUTS
% hf	= figure handle
%
% TC Moran UC Berkeley 2013


%% INITIALIZE FIGURE
hf = figure; hold on; colorbar;

%% CALIFORNIA BOUNDARY
mdir = WB_PARAMS('dir_master');
path_CAbound = fullfile(mdir,'CATCHMENT_CA','boundary','ST_BOUNDARY_DATA.mat');
load(path_CAbound);
caLon = st_boundary.Lon_degE; caLat = st_boundary.Lat_degN;
caLon = caLon(1:8:end); caLat = caLat(1:8:end);	% thin border data to ~1000 points
plot(caLon,caLat,'k','LineWidth',1)
ylim([32,42.5]); xlim([-125,-114])
xlabel('Longitude (degE)')
ylabel('Latitude (degN)')
box on


%% CYCLE THROUGH WATERSHEDS
Nws = length(DIR_WS);
Dlim = [min(D),max(D)];
set(gca,'CLim',Dlim)
for cc = 1:Nws
	d = D(cc);				% data value for this watershed
	dir_ws = DIR_WS{cc};	% relative path for this watershed 
	txt = ['display(["Site=',num2str(ID(cc)),'"]),display(["value=',num2str(d),'"])'];
	%% LOAD BOUNDARY DATA
	path_bound = fullfile(mdir,dir_ws,'boundary','ST_BOUNDARY_DATA.mat');
	load(path_bound)
	lat = st_boundary.Lat_degN;
	lon = st_boundary.Lon_degE;
	lat_ref = st_boundary.ref_point.Latitude;
	lon_ref = st_boundary.ref_point.Longitude;
	while length(lat) > 400		% reduce number of points to < 400
		lat = lat(1:2:end);
		lon = lon(1:2:end);
	end
	ws_area = polyarea(lon,lat);
	%% SET ALTITUDE RELATIVE TO CATCHMENT SIZE
	% Smallest sites need highest alt
	if ws_area == 0
		alt = 100;
	elseif ws_area < 20000
		alt = 100*(1-log(ws_area)/10);
	else
		alt = 0;
	end
	%% PLOT
	alt_vec = ones(size(lat))*alt;
	hp = patch(lon,lat,alt_vec,'w','EdgeColor','k','Linewidth',0.5,'ButtonDownFcn',txt );
	set(hp,'FaceColor','flat','FaceVertexCData',d,'CDataMapping','scaled')
	
end
