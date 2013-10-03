function file_names = get_file_names2(directory, name_filt)

% GET_FILE_NAMES2 returns a cell array with names of files in specified
% directory, or current directory if not specified.  Output excludes
% subdirectories. 
%
% INPUTS
% directory = full address of directory to check; otherwise current dir
% name_filt = file name filter, e.g. '.txt' to return only .txt files
%
% OUTPUTS
% file_names = cell array of strings of all files in specified directory
%
% Thomas Moran
% UC Berkeley, 2010

if nargin == 0 % set directory to current if not an input argument
    directory = pwd;    
end %if nargin
if nargin < 2
    name_filt = [];
end

% get file names / exclude directories
st_file_list = dir(directory);
num_files = length(st_file_list);
ii = 1;
for nn = 1:num_files;
    chk_dir = st_file_list(nn).isdir;
    
    if chk_dir == 0
        file_name = st_file_list(nn).name;
        
        if ~isempty(name_filt)
            chkfilt = strfind(file_name,name_filt);
            if isempty(chkfilt)
                % don't include this file name if filter string isn't part
                % of name
                continue
            end
        end
        
        file_names{ii} = file_name;
        ii = ii + 1;
    end %if
end %for


% assign empty matrix if no dirs found
if ii == 1
    file_names = [];
end %if kk