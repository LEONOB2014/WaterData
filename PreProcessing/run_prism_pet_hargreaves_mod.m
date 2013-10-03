function run_prism_pet_hargreaves_mod(data_yrs)

% RUN_PRISM_PET_HARGREAVES_MOD(dir_TMin, dir_Tmax, dir_PET) calculates PET using Hargreaves
% estimation for the PRISM grid using average monthly max temp (Tmax) and average
% monthly minimum temp (Tmin) grid values
%
% INPUTS
% data_yrs = calendar years of data to process
% 
% OUTPUTS
% saved products in dir_PET directory
% Hargreaves PET is calculated in mm/day
%
% TC Moran UC Berkeley 2011

%% DEFAULTS

if nargin < 1    
    data_yrs = 1895:2012;
end 

st_Tmin = get_data_type_info('PRISM','TMIN');
dir_Tmin = st_Tmin.dir_data_source;
fname_Tmin = st_Tmin.data_mat_fname;
idxYYYY = strfind(fname_Tmin,'YYYY');
name_tmin = fname_Tmin(1:idxYYYY-1);

st_Tmax = get_data_type_info('PRISM','TMAX');
dir_Tmax = st_Tmax.dir_data_source;
fname_Tmax = st_Tmax.data_mat_fname;
idxYYYY = strfind(fname_Tmax,'YYYY');
name_tmax = fname_Tmax(1:idxYYYY-1);

st_Prec = get_data_type_info('PRISM','PRECIP');
dir_Prec = st_Prec.dir_data_source;
fname_Prec = st_Prec.data_mat_fname;
idxYYYY = strfind(fname_Prec,'YYYY');
name_prec = fname_Prec(1:idxYYYY-1);

st_PET  = get_data_type_info('PRISM','HMPET');
dir_PET = st_PET.dir_data_source;
fname_PET = st_PET.data_mat_fname;
idxYYYY = strfind(fname_PET,'YYYY');
name_petH = fname_PET(1:idxYYYY-1);

dir_orig = pwd;

% NaN Identifiers = number that represents NaN for int data
nan_id = -9999;


%% CALENDAR
% Mid-month doy for calendar year
doy_cy_midmonth = [15, 46, 74, 105, 135, 166, 196, 227, 258, 288, 319, 349];
ndays_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
% Mid-month doy (15th of each month) for water year
% doy_wy_midmonth = [288, 319, 349, 15, 46, 74, 105, 135, 166, 196, 227, 258];

%% MAKE PRISM DATA GRID
st_grid_params = data_grid_info('PRISM');
stg = st_grid_params;
[XYgrid, refmat] = data_grid_lattice(stg.pix_sz, stg.ulx, stg.uly, stg.nrows, stg.mcols);
grid_lat = XYgrid(:,:,2);

%% CYCLE THROUGH DATA YEARS
num_yrs = length(data_yrs);
for yy = 1:num_yrs
    yr = data_yrs(yy);
    display(['Processing ',num2str(yr)])
    % filenames
    fname_tmin = [name_tmin,num2str(yr),'.mat'];
    fname_tmax = [name_tmax,num2str(yr),'.mat'];
    fname_petH = [name_petH,num2str(yr),'.mat'];
    fname_prec = [name_prec,num2str(yr),'.mat'];
    % load tmin data
    cd(dir_Tmin)
    load(fname_tmin)
    d_tmin = st_grid_data.data;     % PRISM T data grids units C*100, int16
    d_tmin = double(d_tmin);        % Convert to double 
    d_tmin(d_tmin==nan_id) = NaN;   % Convert NaN designators to NaNs
    d_tmin = d_tmin/100;            % Convert to C
    % load tmax data
    cd(dir_Tmax)
    load(fname_tmax)
    d_tmax = st_grid_data.data;
    d_tmax = double(d_tmax);        % Convert to double 
    d_tmax(d_tmax==nan_id) = NaN;   % Convert NaN designators to NaNs
    d_tmax = d_tmax/100;            % Convert to C
    
    % load precip data
    cd(dir_Prec)
    load(fname_prec)
    d_prec = st_grid_data.data;     % Precip (mm) int16
    d_prec = double(d_prec);
    d_prec(d_prec==nan_id) = NaN;   
    cd(dir_orig)
    
    % Calculate PET (aka ETo)
    this_ETo_mm = [];
    for mm = 1:12
       d_tmin_m = squeeze(d_tmin(:,:,mm));
       d_tmax_m = squeeze(d_tmax(:,:,mm));
       d_prec_m = squeeze(d_prec(:,:,mm));
       this_doy = doy_cy_midmonth(mm);
       % Avg ETo for month
       this_month_avg_ETo = calc_pet_hargreaves_mod(d_tmax_m, d_tmin_m, d_prec_m, grid_lat, this_doy);
       % Total ETo depth per month
       this_ETo_mm(:,:,mm) = this_month_avg_ETo.*ndays_month(mm); 
    end
    % get rid of any stray complex numbers
    this_ETo_mm = abs(this_ETo_mm);
    this_ETo_mm(:,:,13) = sum(this_ETo_mm(:,:,1:12),3);
    
    % format data to int16 for quick processing downstream
    this_ETo_mm(isnan(this_ETo_mm)) = nan_id;
    this_ETo_mm = int16(this_ETo_mm);
    
    % Save data for this year in structure; use old structure, replace data field
    st_grid_data.data = this_ETo_mm;
    cd(dir_PET)
    eval_str = ['save ',fname_petH, ' st_grid_data'];
    eval(eval_str)
    
end %for yy

cd(dir_orig)

xx = 1;