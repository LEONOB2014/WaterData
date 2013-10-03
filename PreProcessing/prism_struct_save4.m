function prism_struct_save4(st_data_type, month1, data_years, fname_str)

% PRISM_STRUCT_SAVE extracts PRISM data from source files and saves them in
% a MATLAB structure for further processing
%
% INPUTS
% st_data_type      = structure with various data type info
% month1            = first month of water year, e.g 10 = Oct-Sep year, 1 = Jan-Dec year
% data_years        = specifies which data years to process, empty [] = all
% fname_str         = identifying string for data file, e.g. '.grd'
%
% TC Moran UC Berkeley 2011

%% DEFAULTS AND SETUP
%  EXTRACT DATA TYPE INFO FROM STRUCTURE
if nargin < 1
    data_dir    = '/Users/tcmoran/Desktop/Summer 2010/PRISM/Precip Data/Consolidated2';
    data_source = 'PRISM';
    data_type   = 'PRECIP';
    data_fname  = 'us_ppt_YYYY.MM.grd';
    yearly_tot  = 'sum';
    data_units  = 'mm';
    data_NaN    = -9999;
else
    data_dir    = st_data_type.dir_data_source;
    data_source = upper(st_data_type.data_source);
    data_type   = upper(st_data_type.data_type);
    data_fname  = st_data_type.data_filename;
    yearly_tot  = st_data_type.yearly_tot_type;
    data_units  = st_data_type.data_units;
    data_NaN    = st_data_type.data_NaN; % NaN identifier
end %if nargin

% Set data unit multiplier based on data_type
if strcmp(data_type,'PRECIP')
    unit_mult = (1/100); % PRISM PRECIP COMES IN MM*100, CHANGE TO MM
else
    unit_mult = 1;      % TEMP DATA COMES IN C*100, LEAVE AS THAT 
end


if nargin < 2
    month1 = 1; % default to calendar year
end %if nargin

if nargin < 3 
   data_years = []; % default to all data years
end

if nargin < 4
  prism_str{1} = '.grd';
else
   prism_str{1} = fname_str; 
end

curr_dir = cd(data_dir);


%% DETERMINE WHAT PRISM DATA ARE PRESENT
file_names = get_file_names;
% find PRISM grid data file names in this directory
prism_source_fnames = find_full_string(file_names, prism_str);

% get indices for YYYY years and MM months in file name
idxYYYY = strfind(data_fname, 'YYYY');
idxMM   = strfind(data_fname, 'MM');

years = get_years_from_fnames(data_fname, data_dir);

% % pull out calendar years from each file name
% for ff = 1:size(prism_source_fnames,2)
%     ch_yr = prism_source_fnames{ff}(idxYYYY:idxYYYY+3);  % character years
%     years(ff) = str2num(ch_yr);     % number years
% end %for ff
% years = unique(years);

% process only specified years if provided as input
if ~isempty(data_years)
   iyrs = ismember(years,data_years); 
   years = years(iyrs);
end


%% DEFINE MONTHS IN YEAR
[months, year_type] = calc_months_wy(month1);

%% CYCLE THROUGH YEARS
miss_data = [];
jj = 1;
kk = 1;
for yy = 1:length(years)
    year = years(yy);
    disp(['Converting Calendar Year ',num2str(year)])
    this_year_grid_data = [];
    st = struct;
    mo_chk = 0;     % indicator for missing data months
    for mm = 1:12
        month = months(mm);
        
        % move to next year if month 1 follows 12
        if mm > 1 && month == 1
            year = year + 1;
        end %if
        
        % convert month to 2 digit number for PRISM file name check
        ch_MM = num2str(month);
        if month < 10
            ch_MM = ['0',ch_MM];
        end
        
        ch_YYYY = num2str(year);
        % insert this year YYYY in filename
        this_filename = [data_fname(1:idxYYYY-1), ch_YYYY, data_fname(idxYYYY+4:end)];
        % insert this month MM in filename
        this_filename = [this_filename(1:idxMM-1), ch_MM, this_filename(idxMM+2:end)]
        % check that file exists
        this_fname{1} = this_filename;
        chk_prism_file = find_full_string(prism_source_fnames, this_fname);
        if ~isempty(chk_prism_file)
            this_fullpath = fullfile(data_dir,this_filename);
            Zdata = arcgridread(this_fullpath);
            this_year_grid_data(:,:,mm) = Zdata;
        else
            miss_data(jj,:) = [year, month];
            jj = jj+1;
            mo_chk = 1;
            continue
        end %if
        
    end %for mm
    
    % check that all months present for this water year
    % do not save this year structure if missing data
    if mo_chk == 1
        disp(['Missing At Least One Month of Data for Water Year ',num2str(year)])
%         continue
    end %if
    
    % keep track of which years have data for complete water year
    yr_complete(kk,1) = year;
    kk = kk+1;
    
    % calculate year total as month 13
    if size(this_year_grid_data,3)==12
        if strcmp('sum',yearly_tot)
            this_year_grid_data(:,:,13) = sum(this_year_grid_data(:,:,1:12),3);
            st.axes = {'Lat Axis','Lon Axis','Months (13 = Sum)'};
        elseif strcmp('avg',yearly_tot)
            this_year_grid_data(:,:,13) = mean(this_year_grid_data(:,:,1:12),3);
            st.axes = {'Lat Axis','Lon Axis','Months (13 = Avg)'};
        end
    else
        this_year_grid_data(:,:,13) = NaN(size(this_year_grid_data,1),size(this_year_grid_data,2));
    end
    
    % Convert to desired units using unit_mult, e.g. Precip -> mm
    this_year_grid_data = this_year_grid_data*unit_mult;

    % This is a bit messy, but we want to use NaN placeholders rather than
    % NaNs to save space and increase processing speed downstream
    this_year_grid_data(isnan(this_year_grid_data)) = data_NaN;
    
    % Then convert to signed 16 bit integer
    this_year_grid_data = int16(this_year_grid_data);
    
    st.data = this_year_grid_data;
%     st.axes = {'Lat Axis','Lon Axis','Months (13 = Sum)'};
    st.year = year;
    st.months = [months, 13];   % include month 13 as sum
    st.year_type = year_type;
    st_grid_data = st;
    
    year_str = num2str(year);
    
    st_file_name = ['ST_PRISM_',data_type,'_',year_type,'_',year_str];
    expression = ['save ',st_file_name,' st_grid_data'];
    eval(expression);
    
end %for ii

%% SAVE TEXT FILES
% save text files with sequential years and missing data month info
% write tab-delimited text file listing sequential calendar years of PRISM data
% fname_calyears = ['PRISM_years_',year_type,'_',ch_time_stamp,'.txt'];
% dlmwrite(fname_calyears, yr_seq,'\t')
% tab-delimited text file of missing data months
time_stamp = datestr(now,30);
ch_time_stamp = num2str(time_stamp);
fname_missdata = [data_source,'_',data_type,'_missing_data_months_',ch_time_stamp,'.txt'];
dlmwrite(fname_missdata,miss_data,'\t')
% tab-delimited text file of valid water years
fname_validyr = [data_source,'_',data_type,'_valid_years_',year_type,'_',ch_time_stamp,'.txt'];
dlmwrite(fname_validyr,yr_complete,'\t')

% change back to original directory
cd(curr_dir)
