function success = calc_gridprecip_gagerunoff3(dir_catch, dir_prod,last_year)

% CALC_GRIDPRECIP_GAGERUNOFF(directory) calculates the difference between
% grid precipitation and gage runoff data and saves result in the products
% subdirectory of the catchment directory
%
% INPUTS
% dir_catch     = absolute path to catchment directory
% dir_prod      = data product directory name
% last_year     = last year of natural flows (optional)
%
% OUTPUTS
% success       = 0 or 1 indication of success for this catchment directory
% saved products in data product directory
%
% TCMoran UC Berkeley 2011

%% DIRECTORIES
if nargin < 1
    dir_catch = uigetdir;
end %nargin
if nargin < 2
    dir_prod = 'DATA_PRODUCTS';
end
if nargin < 3
    last_year = 9999;
end

% move to catchment directory
last_dir = cd(dir_catch);
% make product directory if not already here
if ~isdir(dir_prod)
    mkdir(dir_prod)
end %if


%% GET DATA FROM GRID PRECIP AND GAGE RUNOFF DIRECTORIES

% PRISM precip data
dir_precip = 'GRID_PRISM/GRID_PRISM_PRECIP';
if isdir(dir_precip)
    last_dir = cd(dir_precip);
else
    display(['Precipitation Directory ',dir_precip,' not found in Catchment Directory ',dir_catch])
    success = 0;
    return
end % if isdir

precip_yr = dlmread('GRID_DATA_WY_MONTHLY_WEIGHTED_MEAN.txt','\t',2,0);
P_mm = precip_yr(:,14); % last row is annual total
% some data is in mm*100, check for this
if mean(P_mm) > 5e3 % mean will be less than 5m
    P_mm = P_mm/100;
end
P_yr = precip_yr(:,1);

cd(last_dir)

%% USGS Gage Runoff Data
dir_runoff = 'GAGE_RUNOFF';
dir_runoff_est = 'WB_RUNOFF';
if isdir(dir_runoff) % check for runoff directory
    cd(dir_runoff)
    fnames_rdir = get_file_names(pwd);
    if isempty(fnames_rdir)
        display(['Runoff data not found for Catchment Directory ',dir_catch])
        success = 0;
        return
    end
    runoff_yr_ndays = dlmread('RUNOFF_QGAGE_yr_R_ndays.txt','\t',1,0);
    fname_prod = ['PRODUCT_PRDIFF_PRISMp_GAGEr.txt'];
    col_text = ['Year,','P-R(mm),','P(mm),','R(mm),','R_numdatadays'];
elseif isdir(dir_runoff_est) % use estimated runoff if not a gaged catchment
    cd(dir_runoff_est)
    fnames_rdir = get_file_names;
    if isempty(fnames_rdir)
        display(['Runoff data not found for Catchment Directory ',dir_catch])
        success = 0;
        return
    end
    runoff_yr_ndays = dlmread('RUNOFF_WBest_yr_R_RefSite.txt','\t',1,0);
    fname_prod = ['PRODUCT_ESTet_PRISMp_ESTr.txt'];
    col_text = ['Year,','ETest(mm),','P(mm),','Rest(mm),','ETest_sitenum'];
else
    display(['Runoff Data not found in Catchment Directory ',dir_catch])
    success = 0;
    return
end % if isdir
cd(dir_catch)

%% EXCLUDE YEARS AFTER 'last_year'
R_yr = runoff_yr_ndays(:,1);
chkyr = R_yr <= last_year;
runoff_yr_ndays = runoff_yr_ndays(chkyr,:);
R_yr = runoff_yr_ndays(:,1);
R_mm = runoff_yr_ndays(:,2);
R_ndays = abs(runoff_yr_ndays(:,3));

%% CALCULATE DIFFERENCE OF COMMON YEARS
% find common years
[chk, loc] = ismember(R_yr, P_yr,'rows');
% row indexes for common years for R and P
R_idx = chk;        % logical index
P_idx = loc(chk);   % reference index

yrs = R_yr(R_idx);
R_ndays = R_ndays(R_idx);
R_mm = R_mm(R_idx);
P_mm = P_mm(P_idx);
dPR_mm = P_mm - R_mm;

data_out = [yrs,dPR_mm,P_mm,R_mm,R_ndays];

%% SAVE TEXT FILE TO PRODUCTS DIRECTORY
cd(dir_prod)
dlmwrite(fname_prod,col_text,'')
dlmwrite(fname_prod,data_out,'delimiter','\t','precision','%.0f','-append')

% back to original directory
cd(last_dir)
success = 1;

xx = 1;