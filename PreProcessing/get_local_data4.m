function st_grid_data = get_local_data4(st_data_type, dir_prod, data_row, data_col, cyears, month1, force_chk)

% GET_LOCAL_DATA returns grid data for cells included in row, col, years.
% This version, '4', assumes that grid data has been processed into .mat
% structure format, and makes some changes to how PRISM data is processed.
%
% INPUTS
% dir_data = full path to directory that holds data
% dir_prod = full path to directory with data products for this data type
% data_row = row indices for data region of interest
% data_col = column indices data region of interest
% cyears   = calendar years of data to retrieve ([] = all years)
% month1   = integer btw 1:12 indicating first month for year of query
% year_type = type of year for inquiry, e.g. Calendar Year 'CY' or Water Year 'WY'
%
% OUTPUTS
% st_grid_data = [DataValue_Row x DataValue_Col x Year x Month]
%
% Thomas Moran
% UC Berkeley, 2010


%% INITIALIZE
dir_data_source = st_data_type.dir_data_source;
data_source     = st_data_type.data_source;
data_type       = st_data_type.data_type;
data_fname      = st_data_type.data_mat_fname;
yearly_tot      = st_data_type.yearly_tot_type;

% Define NaN placeholders, this should be in st_data_type
if isfield(st_data_type,'data_NaN')
    nan_num = st_data_type.data_NaN;
else nan_num = NaN;
end

last_dir = cd(dir_data_source);

idxYYYY = strfind(data_fname,'YYYY'); % if empty then assume data is multi-year mean

%% SWITCH BETWEEN YEARLY AND AVERAGE DATA ARRAYS
if isempty(idxYYYY)
    grid_data = get_local_data_avg(dir_data_source,data_fname,data_row,data_col,nan_num);
    st.data = grid_data;
    st.years = [];
    
    [months, year_type] = calc_months_wy(month1);
    st.year_type  = year_type;
    st.months = months;
    st_grid_data = st;
    
    cd(last_dir)
    return
end

%% CHECK FOR DATA IN DIR
fnames = get_file_names2(pwd,data_fname(1:idxYYYY-1));
% check whether data has been processed into water years MATLAB
[months, year_type] = calc_months_wy(month1);

% Find which years have data files
data_years = get_years_from_fnames(data_fname, dir_data_source);

% Load all years if years not specified as input
if isempty(cyears)
    years = data_years;
else
    iy = ismember(cyears,data_years);
    years = cyears(iy);
end %nargin


%% LOAD DATA FROM PREVIOUSLY SAVED .MAT STRUCTURE
%  look for designated year type
if strcmp(year_type,'CY')
    yrmin = min(years);
else
    yrmin = min(years)+1;
end
yrmax = max(years);
fname_st = ['ST_GRID_DATA_',data_type,'_',year_type,'_',num2str(yrmin),'_',num2str(yrmax),'.mat'];
fnames_prod = get_file_names(dir_prod);
fname_st_chk = ismember(fname_st, fnames_prod);
% Load data from saved structure if available
if ~force_chk & fname_st_chk
    cd(dir_prod)
    load_exp = ['load ',fname_st];
    eval(load_exp)
    st_grid_data = st_grid_data.data;
    cd(last_dir)
    return
end %if

%% OTHERWISE CYCLE THROUGH DATA YEARS
jj = 1;
nn = 1;
cy_prior = false;   % marker for whether current data year was already loaded as
% as 2nd half of prior water year
for yy = 1:length(years)
    yr = years(yy);
    
    st_grid_data = struct; % imported data structures
    D =     []; % imported data arrays from UMont ET
    ETmm =  []; % imported data arrays from UW ET
    BESSet =[]; % BESS ET data imports
    BESS =  []; % Other BESS data imports
    
    this_year_data = [];
    % import CY structure
    this_yr_file_name = [data_fname(1:idxYYYY-1),num2str(yr),'.mat'];
    % Will need 2 years of data unless just a calendar year
    this_yr_file_name2 = [data_fname(1:idxYYYY-1),num2str(yr+1),'.mat'];
    
    fname_chk  = ismember(this_yr_file_name, fnames);
    fname_chk2 = ismember(this_yr_file_name2, fnames);
    
    if month1 == 1 || fname_chk && fname_chk2
        
        %% LOAD FIRST DATA YEAR
        display(['Importing Data Year ',num2str(yr)])
        
        % unless the data is already available from the end of the last wy
        if ~cy_prior
            eval_str = ['load ',this_yr_file_name];
            eval(eval_str)
            
            % get whole data array
            % (n,m,1-12) = months of data (e.g. Oct-Sep for CA Water Year)
            % (n,m,13)   = cumulative water year data (sum of 1:12)
            
            % *** DETERMINE WHAT TYPE OF PRE-PROCESSED DATA THIS IS ****
            % If it is PRISM data, it will be in a structure with field 'data'
            if isfield(st_grid_data,'data')
                data_yr1 = st_grid_data.data;
            elseif ~isempty(D)
                data_yr1 = D;
                clear D
            elseif ~isempty(ETmm)
                data_yr1 = ETmm;
                clear ETmm
            elseif ~isempty(BESSet)
                data_yr1 = BESSet;
                clear BESSet;
            elseif ~isempty(BESS)
                data_yr1 = BESS;
                clear BESS;
            elseif isfield(st_cimis_pet,'monthly_pet_tot_mm')
                data_yr1 = st_cimis_pet.monthly_pet_tot_mm;
                clear st_cimis_pet
            end
            
        else
            % use data from end of last wy for beginning of this wy
            data_yr1 = data_yr2;
            clear data_yr2
        end %if ~cy_prior
        
        % grab sub-array of data in vicinity of boundary using row, col
        year1_data = data_yr1(data_row, data_col, :);
        clear data_yr1
        % convert to double with NaNs as necessary
        year1_data = double(year1_data);
        year1_data(year1_data == nan_num) = NaN;
        % sum months to yearly value if not already done
        if size(year1_data,3) == 12
            year1_data(:,:,13) = nansum(year1_data,3);
        end
        
        %% LOAD 2ND DATA YEAR UNLESS YEAR TYPE IS CY
        if strmatch('CY',year_type)
        else    % load 2nd year of data
            st_grid_data = struct; D = []; ETmm = [];% reinitialize var names
            eval_str2= ['load ',this_yr_file_name2];
            eval(eval_str2)
            if isfield(st_grid_data,'data')
                data_yr2 = st_grid_data.data;
            elseif ~isempty(D)
                data_yr2 = D;
                clear D
            elseif ~isempty(ETmm)
                data_yr2 = ETmm;
                clear ETmm
            elseif ~isempty(BESSet)
                data_yr2 = BESSet;
                clear BESSet;
            elseif ~isempty(BESS)
                data_yr2 = BESS;
                clear BESS;
            elseif isfield(st_cimis_pet,'monthly_pet_tot_mm')
                data_yr2 = st_cimis_pet.monthly_pet_tot_mm;
                clear st_cimis_pet
            end
            year2_data = data_yr2(data_row,data_col,:);
            % clear data_yr2
            % USE data_yr2 FOR BEGINNING OF NEXT WY
            cy_prior = true;
            % convert to double with nans as necessary
            year2_data = double(year2_data);
            year2_data(year2_data == nan_num) = NaN;
            % sum months to yearly value if not already done
            if size(year2_data,3) == 12
                year2_data(:,:,13) = nansum(year2_data,3);
            end
        end
        
        % pull out water year relative to month1 from calendar year data
        if size(year1_data,3) >= 12
            this_year_data = year1_data;
            for mm = 1:12
                month = months(mm);
                grid_data(:,:,yy,mm) = this_year_data(:,:,month);
                % move to next year's data
                if mm < 12 & months(mm+1) < months(mm)
                    this_year_data = year2_data;
                    yr = yr+1;
                end
            end
        else
            grid_data(:,:,yy) = year1_data;
        end
        
        if strcmp('sum',yearly_tot)
            grid_data(:,:,yy,13) = nansum(grid_data(:,:,yy,1:12),4);
            st.descrip = {'DataRow','DataCol','Year','Month_13Sum'};
        elseif strcmp('avg',yearly_tot)
            grid_data(:,:,yy,13) = nanmean(grid_data(:,:,yy,1:12),4);
            st.descrip = {'DataRow','DataCol','Year','Month_13Avg'};
        elseif strcmp('code',yearly_tot)
            grid_data = grid_data; % no manip for codes
            st.descrip = {'DataRow','DataCol','Year'};
        end
        
        valid_data_yr(nn,1) = yr;
        nn = nn+1;
    else
        no_data_yr(jj,1) = yr;
        jj = jj+1;
        display(['Data Missing for Year ',num2str(yr)])
        
    end %if fname_chk
    
end %for yy

% st.descrip = '[DataRow, DataCol, Year, Month]';
st.data = grid_data;
st.years = valid_data_yr;
st.year_type  = year_type;
st.months = months;

st_grid_data = st;
cd(last_dir)

%% FUNCTION FOR ARRAYS OF MULTI-YEAR AVERAGES
function  grid_data = get_local_data_avg(dir_data_source,data_fname,data_row,data_col,nan_num)

% initialize various variables that may be in data_fname file. Totally
% wonky, but works for now.
st_cimis_pet = struct;

dir_last = cd(dir_data_source);
load_str = ['load ',data_fname];
eval(load_str)

% check which data type was loaded
if isfield(st_cimis_pet,'monthly_pet_tot_mm') % CIMIS PET data
    datacy = st_cimis_pet.monthly_pet_tot_mm;
    % convert data from CY to WY in dimension 3
    datawy = cat(3,datacy(:,:,10:12),datacy(:,:,1:9),datacy(:,:,13));
end

% grab sub-array of data in vicinity of boundary using row, col
data_local = datawy(data_row, data_col, :);
% convert to double with NaNs as necessary
data_local = double(data_local);
data_local(data_local == nan_num) = NaN;
% sum months to yearly value if not already done
if size(data_local,3) == 12
    data_local(:,:,13) = nansum(year1_data,3);
end

grid_data = data_local;

