function preproc_PRISM(data_type)

% PREPROC_PRISM_PRECIP(data_type) preprocesses PRISM precip data from .grd format to
% .mat structures

%% MAKE DATA INFO STRUCTURE
st_data_type = get_data_type_info('PRISM', data_type);
% data file name for .mat structure
mat_fname = ['ST_PRISM_',data_type,'_CY_YYYY.mat'];
month1 = 1; % Calendar Years

%% EXTRACT VARIABLES FROM DATA TYPE ARRAY, MOVE TO DATA SOURCE DIR

dir_data_source = st_data_type.dir_data_source;
data_source     = st_data_type.data_source;
data_type       = st_data_type.data_type;
data_fname      = st_data_type.data_filename;
last_dir = cd(dir_data_source);

%% CHECK FOR .grd DATA IN DIR
fnames = get_file_names;
% get only .grd file names
grd_yr_idx = strfind(data_fname,'YYYY');
data_fname_chk = data_fname(1:grd_yr_idx-1);
fnames_grd = find_full_string(fnames,{data_fname_chk});
if isempty(fnames_grd)
    display(['PRISM .grd files not found in ',dir_data_source,', check location and try again'])
    return
else
    for nn = 1:length(fnames_grd)
        gyr(nn) = str2num(fnames_grd{nn}(grd_yr_idx:grd_yr_idx+3));
    end
    % unique data years for .grd files
    yr_grd = unique(gyr)';
end

%% COMPARE WITH .mat DATA IN DIR
mat_yr_idx = strfind(mat_fname,'YYYY');
fnames_mat = find_full_string(fnames,{mat_fname(1:mat_yr_idx-1),'.mat'});
if isempty(fnames_mat)
    yr_mat = [];
else
    for nn = 1:length(fnames_mat)
        myr(nn) = str2num(fnames_mat{nn}(mat_yr_idx:mat_yr_idx+3));
    end
    % unique data years for .grd files
    yr_mat = unique(myr)';
end

chk_yrs = ~ismember(yr_grd,yr_mat);
% Exit if .grd and .mat data years match -> all data already pre-processed
if max(chk_yrs)==0
    display(['All PRISM ',data_type,' Data Pre-processed'])
    return
end
yr_grd = yr_grd(chk_yrs);

%% PRE-PROCESS .grd DATA ONLY FOR YEARS NOT ALREADY DONE
prism_struct_save4(st_data_type, month1, yr_grd, data_fname_chk)

cd(last_dir)
xx = 1;

