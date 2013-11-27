function hfig = plot_intensity2(st_grid_data,intvl_type,year)

% PLOT_INTENSITY2 plots grid data as an intensity plot with watershed
% boundary
%
% TC Moran UC Berkely 2011

if nargin < 2
    intvl_type = 'all';  % default to mean for all years
end

st      = st_grid_data;
dsource = st.data_type.data_source;
dtype   = st.data_type.data_type;
data    = st.pixel_data.data;
tot_type= st.data_type.yearly_tot_type;
years   = st.pixel_data.years;
refLon  = st.boundary.ref_point.Longitude;
refLat  = st.boundary.ref_point.Latitude;
grid_proj=st.pixel_grid.grid_parameters.projection.name;

if strcmp(intvl_type, 'year')
    if nargin < 3
        year = years(end); % default to last data year
    end
    % find index of input year
    iyr = find(years == year);
    if isempty(iyr)
        display('Data not found for input year')
        return
    end
    % annual data is month 13
    data = squeeze(data(:,:,iyr,13));
    data = abs(data); % eliminate any errant complex numbers
elseif strcmp(intvl_type,'all')
    if strncmp(tot_type,'code',4)
        data = data(:,:,end); % use last year for pixel codes e.g. IGBP
    elseif ndims(data) == 4
        data = data(:,:,:,13);
        data = abs(data); % eliminate any errant complex numbers
        data = nanmean(data,3);
    elseif ndims(data) == 3 % just one year or mean values
        data = abs(data); % eliminate any errant complex numbers
        data = data(:,:,13);
    end
    
else
    hfig = [];
    return
end


% find mean and std dev to scale intensity plot
if strcmp(tot_type,'code_igbp')
    dmin = 0; dmax = 17; % applicable for BESS IGBP
else
    d = data(:);
    % exclude NaNs from mean and std calcs
    inan = isnan(d);
    d = d(~inan);
    data_mean = mean(d);
    data_std  = std(d);
    dmax = data_mean + 3*data_std;
    dmin = data_mean - 3*data_std;
    if dmin < 0
        dmin = 0;
    end %if
end

% pixel coords (center of pixel)
X = st.pixel_grid.pix_X_ctr;
Y = st.pixel_grid.pix_Y_ctr;
% pixel size
px = st.pixel_grid.grid_parameters.pix_sz;
% pcolor plots wrt corner having the smallest x-y index, not center,
% so shift pixels up and to left by 1/2 pixel for plotting
X = X - 0.5*px;
Y = Y + 0.5*px; % Checked as of 1/07/12

% if grid is sinusoidal then convert to geographic coords
if strmatch(grid_proj,'sinusoidal')
    [Y,X] = Sin2Geo(X, Y);
elseif strmatch(grid_proj,'TealeAlbers')
    datum_str = st_grid_data.boundary.LatLon_projection;
    strindx = strfind(datum_str,'NAD');
    datum = datum_str(strindx:end);
    st_grid = st.pixel_grid.grid_parameters;
    Xvec = reshape(X,[],1); Yvec = reshape(Y,[],1);
    
    [Yvec,Xvec] = TealeAlbersInv(Xvec,Yvec,st_grid,datum);
    X = reshape(Xvec,size(X));
    Y = reshape(Yvec,size(Y));
end

% boundary polygon
Lat = st.boundary.Lat_degN;
Lon = st.boundary.Lon_degE;

% number of years to plot
num_yr = size(data,3);

% find pixels that are completely outside boundary
pix_weight = st.pixel_grid.pix_weight;
pnan = pix_weight == 0;

% figure
hfig = figure;
% plot boundary
h1 = patch(Lon, Lat, 'w','edgecolor','k','facecolor','none');
xlabel('Longitude (deg E)'); ylabel('Latitude (deg N)');
axis equal
hold on
box on
xLim = xlim; yLim = ylim;

% intensity plot of grid data
h2 = pcolor(X,Y,data);
set(h2, 'edgecolor','none')
caxis([dmin, dmax]);
colorbar
if strcmp(tot_type,'code_igbp')
    cmap = bess_igbp_colormap;
    colormap(cmap);
else
    cmap = flipud(colormap);
    colormap(cmap);
end
% redraw boundary polygon
h1 = patch(Lon, Lat, 'w','edgecolor','k','facecolor','none');
scatter(refLon, refLat,'r','Marker','x','SizeData',12^2,'LineWidth',2);
xlim(xLim); ylim(yLim);
