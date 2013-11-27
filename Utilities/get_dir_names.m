function dir_names = get_dir_names(directory)

% GET_DIR_NAMES returns a cell array with names of subdirectories within
% specified directory.  Excludes '.', '..', and file names. 
%
% INPUTS
% directory = full address of directory to check; otherwise use current
%
% OUTPUTS
% dir_names = cell array of directory name strings, excluding '..' and '.'
%
% Thomas Moran
% UC Berkeley, 2010

if nargin == 0 % set directory to current if not an input argument
    directory = pwd;    
end %if nargin

% get file names / exclude directories
st_list = dir(directory);
num_names = length(st_list);
ii = 1;
for nn = 1:num_names
    chk_dir = st_list(nn).isdir;
    
    if chk_dir == 1
        dir_name = st_list(nn).name;
        
        % exclude '.' and '..' directories
        chk_dot = strfind(dir_name, '.');
        
        if isempty(chk_dot)
            dir_names{ii} = dir_name;
            ii = ii + 1;
        end %if
        
        chk_dot = [];
        
    end %if
    
end %for

% assign empty matrix if no dirs found
if ii == 1
    dir_names = [];
end %if kk