function dparts = dirparts(directory)

% DIRPARTS(directory) returns the separate elements of the full path to the
% input directory
%
% INPUTS
% directory = absoulute directory path
% OUTPUTS
% dparts    = cell array of individual directory elements
%
% TC Moran UC Berkeley 2011

% get file separation character for current platform
fsep = filesep;
% find fsep in directory path
idx = strfind(directory,fsep);
% separate directory strings into cells
dparts{1} = directory(1:idx(1)-1);
for nn = 1:length(idx)-1
    i1 = idx(nn)+1; i2 = idx(nn+1)-1; 
    dparts{nn+1} = directory(i1:i2);
end
% check if last sep is also last character
nchars = size(directory,2);
if idx(end) == nchars
   % if sep char ends 'directory', then done
else
    dparts{nn+2} = directory(idx(end)+1:nchars);
end

% debug line
xx = 1;