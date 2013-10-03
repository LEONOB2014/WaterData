function process_grid_data(dir_catch, data_source, data_type, month1, cyears, force_chk)

% PROCESS_GRID_DATA(dir_catch, data_source, data_type, month1, cyears) does
% preprocessing for grid data. Creates a directory for indicated data type,
% gathers data in vicinity of catchment boundary, and saves a structure
% with data and other properties
%
% INPUTS
% dir_catch     = absolute path to catchment directory with 'boundary' subdir
% data_source = string that identifies which type of data is being processed,
%             e.g. 'PRISM' or 'MODIS'. Must correspond with type in
%             get_data_type_info
% data_type = type of data for this source
%             'precip', 'temp', 'et', etc
% month1    = integer btw 1:12 indicating first month for year of query
%             e.g. 10 for Water Year (Oct-Sep), 1 for Calendar Year (Jan-Dec)
% cyears    = calendar years for inquiry, [] = all years
% 
% OUTPUTS
% structure with data and other properties
% 
% TC Moran UC Berkeley 2011

%% DEFAULT INPUT ARGUMENTS
if nargin < 1
    dir_catch = uigetdir;
end %if
%  default to PRISM for now
if nargin < 2
    data_source = 'PRISM';
end %if nargin
%  default to precip for now
if nargin < 3
    data_type = 'PRECIP';
end %if nargin
% default to water year for now
if nargin < 4
    month1 = 10;
end %if
% default years to all years
if nargin < 5
    cyears = [];
end %if
% default for whether or not to force calculations if file already exists
if nargin < 6
    force_chk = false; % default to not force recalculation 
end
% ** USE THIS TO FORCE CALCULATIONS FOR SPECIFIC DATA TYPE
if strcmp(data_type,'BESS_ET')
    force_chk = true;
end

data_source = upper(data_source); 
data_type = upper(data_type);
dir_orig = cd(dir_catch);

% Define months in year
[~, year_type] = calc_months_wy(month1);

%% STRUCTURE FOR DATA TYPE INFO
st_data_type = get_data_type_info(data_source, data_type);

% dir_data_source = st_data_type.dir_data_source;  % source data directory
dir_grid_source = ['GRID_',data_source];
dir_grid_source_type = [dir_grid_source,'_',data_type];
dir_products = fullfile(dir_catch, dir_grid_source, dir_grid_source_type); % data products directory

%% CHECK FOR EXISTING FILES
fnames_prod = get_file_names(dir_products);
fname_st{1} = 'ST_GRID_DATA_'; fname_st{2} = data_source; fname_st{3} = data_type; 
fname_st{4} = year_type;
fname_ST = find_full_string(fnames_prod,fname_st);
% Skip this calculation if file exists and calculation not forced
if ~isempty(fname_ST)
    fname_ST = fname_ST{1};
    if ~force_chk
        return
    end
end

%% IMPORT SITE INFO
info_fname = 'site_info.csv';
site_info_file = fullfile(dir_catch,info_fname);
st_site_info = import_site_info(site_info_file);

%% LOAD CATCHMENT BOUNDARY STRUCTURE
dir_bound = fullfile(dir_catch, 'boundary');
dir_last = cd(dir_bound);
load('ST_BOUNDARY_DATA.mat');
cd(dir_last)

%% LOAD PIXEL WEIGHTS MASK
dir_grid_source = fullfile(dir_catch, dir_grid_source);
dir_last = cd(dir_grid_source);
fname_grid_info = ['ST_GRID_INFO_',data_source,'.mat'];
load(fname_grid_info);

%% DO LOCAL DATA CALCULATIONS
if ~isdir(dir_products), mkdir(dir_products), end
dir_last = cd(dir_products);

data_col = unique(st_pixels.pix_ref_col);
data_row = unique(st_pixels.pix_ref_row);
yearly_tot = st_data_type.yearly_tot_type;



% **** MAIN FUNCTION *****
st_pix_data = get_local_data4(st_data_type, dir_products, data_row, data_col, cyears, month1, force_chk);




%% APPLY PIXEL WEIGHTS TO DATA
 p3 = size(st_pix_data.data,3); p4 = size(st_pix_data.data,4);
% Running out of memory for large arrays, check size, skip for now if very large
dsize = whos('st_pix_data');
if dsize.bytes < 1e8    % check if smaller than 100MB
    for ii = 1:p3
        for jj = 1:p4
            pix_data_weighted(:,:,ii,jj) = st_pixels.pix_weight.*st_pix_data.data(:,:,ii,jj);
        end %for jj
    end %for ii
else                    % otherwise return empty matrix
    pix_data_weighted = [];
end %if

%% SAVE DATA IN WORKING DIRECTORY
st.data_type = st_data_type;
st.site_info = st_site_info;
st.boundary  = st_boundary;
st.pixel_grid= st_pixels;
st.pixel_data= st_pix_data;
st.pixel_data_weighted = pix_data_weighted;

st_grid_data = st;

% start and stop years for file name
year_start = min(st_pix_data.years);
year_stop  = max(st_pix_data.years);

save_name = ['ST_GRID_DATA_',data_source,'_',data_type,'_',year_type,'_',num2str(year_start),'_',num2str(year_stop)];
save_exp =  ['save ',save_name,' st_grid_data'];
eval(save_exp)

%% INTENSITY PLOT OF GRID DATA
hfig = plot_intensity2(st); % default options will plot mean of all years
saveas(hfig,'CATCHMENT_INTENSITY_MEANALLYEARS.fig')
close(hfig)

cd(dir_orig)

xx = 1;