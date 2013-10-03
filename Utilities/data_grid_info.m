function st_grid_params = data_grid_info(grid_type)

% DATA_GRID_INFO returns grid parameters in a structure
%
%


grid_type = upper(grid_type);

switch grid_type
    %% Precip and Temp grids from OSU Climate Group
    case 'PRISM'
        
        % PRISM data grid parameters: Keep this info elsewhere eventually
        st.type = grid_type;
        st.pix_sz = 0.041667;    % PRISM cell size, degrees Lat, Lon
        st.subpix_N = 4; % number of subpixels per pixel for boundary weighting (linear, areal = subpix_N^2)
        st.units = 'degrees';
        st.ulx = -125.020833333333 + st.pix_sz/2;  % longitude of ctr of upper left pixel (deg E)
        st.uly = 49.93750000       - st.pix_sz/2;  % latitude of ctr of upper left pixel  (deg N)
        st.nrows = 621;        % Total number of rows in PRISM grid
        st.mcols = 1405;       % Total number of columns in PRISM grid
        st.tile = [];
        % Projection Info
        st.projection.name     = 'geographic';  % Lat/Lon
        st.projection.datum    = 'WGS72';            % World Geodetic Spheroid 1972
        st.projection.param(1).name = 'Ellipsoid Name';
        st.projection.param(1).data = 'WGS72';
        st.projection.param(2).name = 'Semi-major Axis (m)';
        st.projection.param(2).data = 6378135.0;
        st.projection.param(3).name = 'Inverse of Flattening Ratio';
        st.projection.param(3).data = 298.26;
        st.grid_info_source = 'http://www.prism.oregonstate.edu/docs/meta/ppt_realtime_monthly.htm';
        
        
        %% Advanced Very High Resolution Radiometer
        % Measurements derived from AVHRR satellite, e.g. UMont ET
    case 'AVHRR'
        st.type = grid_type;
        st.pix_sz = 0.07272727; % square pixel size in degrees Lat, Lon
        st.subpix_N = 4; % number of subpixels per pixel for boundary weighting (linear, areal = subpix_N^2)
        st.units = 'degrees';
        st.ulx =  -179.959;     % longitude of ctr of upper left pixel (deg E)
        st.uly = 89.187;        % latitude of ctr of upper left pixel  (deg N)
        st.nrows = 2091;         % Total number of rows in PRISM grid
        st.mcols = 4950;        % Total number of columns in PRISM grid
        st.tile = [];
        % Projection Info
        % *** DOUBLE CHECK VALIDITY FOR UMONT DATA *****
        st.projection.name     = 'geographic';  % Lat/Lon
        st.projection.datum    = 'WGS72';            % World Geodetic Spheroid 1972
        st.projection.param(1).name = 'Ellipsoid Name';
        st.projection.param(1).data = 'WGS72';
        st.projection.param(2).name = 'Semi-major Axis (m)';
        st.projection.param(2).data = 6378135.0;
        st.projection.param(3).name = 'Inverse of Flattening Ratio';
        st.projection.param(3).data = 298.26;
        st.grid_info_source = 'http://secure.ntsg.umt.edu/projects/index.php/ID/26354646/fuseaction/projects.detail.htm';
        
        
        %% USA05
        % 0.05 degree grid over USA, used for UW ET Grid
    case  'USA05'
        st.type = grid_type;
        st.pix_sz = 0.05;       % square pixel size in degrees Lat, Lon
        st.subpix_N = 4; % number of subpixels per pixel for boundary weighting (linear, areal = subpix_N^2)
        st.units = 'degrees';
        % **** DOUBLE CHECK ORIGIN ALIGNMENT FOR UW DATA ****
        st.ulx =  -125 + st.pix_sz/2;     % longitude of ctr of upper left pixel (deg E)
        st.uly =    53 - st.pix_sz/2;     % latitude of ctr of upper left pixel  (deg N)
        st.nrows = 560;        % Total number of rows in PRISM grid
        st.mcols = 1160;        % Total number of columns in PRISM grid
        st.tile = [];
        % Projection Info
        % *** DOUBLE CHECK VALIDITY FOR UMONT DATA *****
        st.projection.name     = 'geographic';  % Lat/Lon
        st.projection.datum    = 'WGS72';            % World Geodetic Spheroid 1972
        st.projection.param(1).name = 'Ellipsoid Name';
        st.projection.param(1).data = 'WGS72';
        st.projection.param(2).name = 'Semi-major Axis (m)';
        st.projection.param(2).data = 6378135.0;
        st.projection.param(3).name = 'Inverse of Flattening Ratio';
        st.projection.param(3).data = 298.26;
        st.grid_info_source = 'http://';
        
        %% MODIS
    case 'MODIS_CA'
        st.type = grid_type;
        st.pix_sz = 926.6254;  % square pixel size in m
        st.subpix_N = 2; % number of subpixels per pixel for boundary weighting (linear, areal = subpix_N^2)
        st.units = 'meters';
        st.ulx =  -1.1119042e+07;     % X sin coord of ctr of upper left pixel (m)
        st.uly =  4.770731e+06;     % Y sin coord of ctr of upper left pixel (m)
        st.nrows = 1353;        % Total number of rows in PRISM grid
        st.mcols = 1406;        % Total number of columns in PRISM grid
        st.tile = [];
        % Projection Info
        st.projection.name     = 'sinusoidal';  % Sinusoidal
        st.projection.datum    = '';            %
        st.projection.param(1).name = 'Ellipsoid Name';
        st.projection.param(1).data = ' ';
        st.projection.param(2).name = 'Earth Radius (m)';
        st.projection.param(2).data = 6371007.181;
        st.projection.param(3).name = 'Central Meridian';
        st.projection.param(3).data = 0;
        st.grid_info_source = 'http://';
        
        
    case 'TEALE_ALBERS_2KM'    % Native projection is Teale Albers Equal Area California-centric
        st.type = grid_type;
        st.pix_sz = 2000;  % square pixel size in m
        st.subpix_N = 3; % number of subpixels per pixel for boundary weighting (linear, areal = subpix_N^2)
        st.units = 'meters';
        st.ulx =  -399000;     % X coord of ctr of upper left pixel (m)
        st.uly =  449000;     % Y coord of ctr of upper left pixel (m)
        st.nrows = 550;        % Total number of rows in native grid
        st.mcols = 500;        % Total number of columns in native grid
        st.tile = [];
        % Projection Info
        st.projection.name     = 'TealeAlbers';     % Albers Equal Area Teale (California centric)
        st.projection.datum    = 'NAD83';             %
        ii = 1;
        st.projection.param(ii).name = 'Ellipsoid Name';
        st.projection.param(ii).data = 'GRS80 ';  ii = ii+1;
        st.projection.param(ii).name = 'Earth Radius (m)';
        st.projection.param(ii).data = 6378137.0;   ii = ii+1;
        st.projection.param(ii).name = 'Inverse of Flattening Ratio';
        st.projection.param(ii).data = 298.257222101;   ii = ii+1;
        st.projection.param(ii).name = 'Central Meridian (deg E)';
        st.projection.param(ii).data = -120; ii = ii+1;
        st.projection.param(ii).name = 'Latitude of Origin (deg N)';
        st.projection.param(ii).data = 0;    ii = ii+1;
        st.projection.param(ii).name = '1st Standard Parallel (deg N)';
        st.projection.param(ii).data = 34;    ii = ii+1;
        st.projection.param(ii).name = '2nd Standard Parallel (deg N)';
        st.projection.param(ii).data = 40.5; ii = ii+1;
        st.projection.param(ii).name = 'False Easting (m)';
        st.projection.param(ii).data = 0;    ii = ii+1;
        st.projection.param(ii).name = 'False Northing (m)';
        st.projection.param(ii).data = -4000000; ii = ii+1;
        st.grid_info_source = 'http://comet.ucdavis.edu/tools/cimis';
        
    case 'NOAA_HRAP'
        st.type = grid_type;
        st.pix_sz = 4.7625e3 ;  % square pixel linear size (m)
        st.subpix_N = 4; % number of subpixels per pixel for boundary weighting (linear, areal = subpix_N^2)
        st.units = 'meters';
        % Center of NW pixel as described at http://www.emc.ncep.noaa.gov/mmb/ylin/pcpanl/QandA/#GRIDINFO
        st.ulx =  134.039;      % Upper left (NW) pixel center coordinate (deg LonE)
        st.uly =  53.509;       % Upper left (NW) pixel center coordinate (deg LatN)
        st.nrows = 881;         % Total number of rows in native grid
        st.mcols = 1121;        % Total number of columns in native grid
        st.tile = [];
        % Projection Info
        st.projection.name     = 'hrap';  % NOAA HRAP
        st.projection.datum    = '';            %
        st.projection.param(1).name = 'Y-axis Parallel, LonE';
        st.projection.param(1).data = -105.0;
        st.projection.param(2).name = 'Pole Point (I,J)';
        st.projection.param(2).data = [400.5, 1600.5];
        st.projection.param(3).name = '';
        st.projection.param(3).data = [];
        st.grid_info_source = {'http://www.nco.ncep.noaa.gov/pmb/docs/on388/tableb.html#GRID240';...
            'http://www.emc.ncep.noaa.gov/mmb/ylin/pcpanl/QandA/#GRIDINFO'};
        
    case 'VIC_CA'
        st.type = grid_type;
        st.pix_sz = 1/8 ;  % square pixel linear size (deg Lat/Lon)
        st.subpix_N = 10; % number of subpixels per pixel for boundary weighting (linear, areal = subpix_N^2)
        st.units = 'degrees';
        % Center of NW pixel as described at http://www.emc.ncep.noaa.gov/mmb/ylin/pcpanl/QandA/#GRIDINFO
        st.ulx =  -124.4375;      % Upper left (NW) pixel center coordinate (deg LonE)
        st.uly =  43.3125;       % Upper left (NW) pixel center coordinate (deg LatN)
        st.nrows = 88;         % Total number of rows in native grid
        st.mcols = 79;        % Total number of columns in native grid
        st.tile = [];
        % Projection Info
        st.projection.name = 'geographic';
        st.projection.datum    = 'WGS72';            % Assumed, not specified in documentation
        st.projection.param(1).name = 'Ellipsoid Name';
        st.projection.param(1).data = 'WGS72';
        st.projection.param(2).name = 'Semi-major Axis (m)';
        st.projection.param(2).data = 6378135.0;
        st.projection.param(3).name = 'Inverse of Flattening Ratio';
        st.projection.param(3).data = 298.26;
        st.grid_info_source = 'http://www.hydro.washington.edu/Lettenmaier/Data/gridded/index_hamlet.html';
                  
end

st_grid_params = st;
