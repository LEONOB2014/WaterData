function dyears = get_years_from_fnames(fname_format, fdir)

% GET_YEARS_FROM_FNAMES(fname_format, fdir) extracts year numbers from the
% file names in directory fdir with formats that match fname_format
%
% INPUTS
% fname_format  = file name format, specifying years with YYYY
%                 e.g. ST_DATA_STUFF_YYYY.mat
% fdir          = absolute path to directory containing yearly data files
%
% OUTPUTS
% dyears        = vector of years
%
% TC Moran UC Berkeley, 2011

%% INITIALIZE
if nargin < 2
    fdir = uigetdir;
end

%% GET FILE NAMES
% get indices for YYYY years and MM months in file name
idxYYYY = strfind(fname_format, 'YYYY');
% idxMM   = strfind(data_fname, 'MM');

% portion of file name before YYYY, assumes this is consistent for naming convention
fname_str{1} = fname_format(1:idxYYYY-1);

orig_dir = cd(fdir);
file_names = get_file_names;
% find PRISM grid data file names in this directory
fnames = find_full_string(file_names, fname_str);

% pull out calendar years from each file name
for ff = 1:size(fnames,2)
    ch_yr = fnames{ff}(idxYYYY:idxYYYY+3);  % character years
    % check that this yields a number
    yr = str2num(ch_yr);
    if ~isempty(yr)
        years(ff) = yr;
    end
end %for ff
dyears = unique(years');

