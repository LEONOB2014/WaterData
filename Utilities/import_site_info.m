function st_site_info = import_site_info(site_info_file, dir_catch)

% IMPORT_SITE_INFO imports gage site info from a text file in the specified
% format into matlab variables.
%
% INPUTS
% site_info_file = full path and file name of gage site text file, tab
%                   delimited default
% dir_catch = absolute path to catchment directory
% 
% OUTPUTS (may need modification depending on available gage info)
% st_site_info  = 1xN structure with info for N sites in site_info_file
% st_site_info.site_id       = unique identifier for each site that defines catchment (integer)
%             .site_name     = unique site name, used for directory and output naming (text)
%             .site_parent   = number of parent unit for site, e.g. HUC or Water Basin (integer)
%             .site_LatLon   = gage site [Lat, Lon] in decimal degrees, precision of 0.00003
%                               degrees (equivalent 0.1 secs in DMS) req'd for reliable
%                               watershed boundary retrieval via USGS online tool
%             .site_datum    = map projection datum (***WILL BE REQUIRED EVENTUALLY***)
%             .ws_area_km2   = reference area of watershed, if available; used to
%                               validate automated boundary calculation (km2)
%
% TCMoran UC Berkeley 2011

%% INITIALIZE
if nargin < 2, dir_catch = pwd; end
dir_orig = cd(dir_catch); 

%% TEXT FILE FORMAT - MODIFY AS NECESSARY
%  [site_id, site_name, site_parent, latN, lonW, site_datum, site_area_km2]

% total number of columns in text file
num_cols = 7;
% number of header rows
num_header_rows = 1;
% check whether file is .txt ('\t' = tab) or .csv (, delimiter)
ftype = site_info_file(end-2:end);
if strmatch(ftype,'csv')
    delimiter = ',';
else
    delimiter = '\t';
end
% Define text file format (which data in which column)
col_num_site_id     = 1;
col_txt_site_name   = 2;
col_num_site_parent = 3;
col_num_latN        = 4;
col_num_lonW        = 5;
col_txt_datum       = 6;
col_num_ws_area_km2 = 7;


%% Import Text File and Parse Into Number and Text Arrays
[pathname, filename, fileext] = fileparts(site_info_file);
filename = [filename, fileext];
site_info_cells = import_text2(num_cols, delimiter, pathname, filename);

% number of sites is number of rows minus header row
num_sites = size(site_info_cells{1},1)-1;

% preallocate site info structure
st(1,num_sites) = struct('site_id',[],'site_name',[],'site_parent',[],'site_latN',[],...
                 'site_lonW',[],'site_datum',[],'ws_area_km2',[]);

sinfo = site_info_cells;
for ii = 1:num_sites
    
    st(ii).site_parent  = str2num(sinfo{3}{ii+1});
    st(ii).site_id      = sinfo{1}{ii+1};   % this needs to be a string in case site num starts with '0'
    site_name           = sinfo{2}{ii+1};
    % remove extraneous characters
    site_name(strfind(site_name,'"')) = '';
    site_name(strfind(site_name,',')) = '';
    site_name(strfind(site_name,'.')) = '';
    site_name(strfind(site_name,'+')) = '';
    site_name(strfind(site_name,'(')) = '';
    site_name(strfind(site_name,')')) = '';
    st(ii).site_name    = site_name;
    st(ii).site_latN    = str2num(sinfo{4}{ii+1});
    st(ii).site_lonW    = str2num(sinfo{5}{ii+1});
    st(ii).site_datum   = sinfo{6}{ii+1};
    st(ii).ws_area_km2  = str2num(sinfo{7}{ii+1});
    
end %for ii
st_site_info = st;

cd(dir_orig)