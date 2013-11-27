function txt_cell = import_text2(num_cols, delimiter, pathname, filename)

% IMPORT_TEXT2 imports a text file as strings, given number of data columns
% N in text file
%
% INPUTS
% num_cols  = number of columns in text file
% delimiter = delimiter of text file
% pathname = absolute path of directory with text file
% filename = full name of text file
%
% OUTPUTS
% txt_cell = {1xN} cell array of column data strings
%
% Thomas Moran
% UC Berkeley, 2010

if nargin < 3
    [filename, pathname] = uigetfile('*','Select Text File');
end

pathfilename = fullfile(pathname, filename);
fid = fopen(pathfilename);

str_name = ['%s'];
for nn = 2:num_cols
    str_name = [str_name, ' %s'];
end %for nn

txt_cell = textscan(fid, str_name, 'delimiter', delimiter);
fclose(fid);

xx = 1;

