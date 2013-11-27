function [ce_list_rel, ce_list_abs] = import_catchment_list(plist, mdir)

% IMPORT_CATCHMENT_LIST imports a list of catchment directories to a cell
% structure
% 
% INPUTS
% mdir  = absolute path to master directory
% plist = absolute path to catchment list file
%
% OUTPUT
% ce_list_rel = cell array of catchment dirs relative to master dir
% ce_list_abs = cell array of catchment dirs relative to master dir
%
% TC Moran UC Berkeley, 2012

%% INITIALIZE
if nargin < 1
   [flist,plist] = uigetfile('*.txt');
   plist = fullfile(plist,flist);
end
if nargin < 2
    mdir = uigetdir;
end

fid = fopen(plist);
if fid == -1
    display('Need valid absolute path to catchment text file list')
    return
end
%% RELATIVE PATHS DIRECTLY FROM LIST
% import relative paths to cell array
ce_list_rel = textscan(fid,'%s','HeaderLines',1);
ce_list_rel = ce_list_rel{1};
% find and remove comment ('%') lines
comment_chk = ~strncmp(ce_list_rel,'%',1);
ce_list_rel = ce_list_rel(comment_chk);

%% ABSOLUTE PATHS IF MDIR PROVIDED
if isempty(mdir); ce_list_abs = {}; return; end
ncatchs = length(ce_list_rel); % # of catchments
for nn = 1:ncatchs
    catchments_togo = ncatchs - nn;
    dcatch = ce_list_rel{nn};
    ce_list_abs{nn,1} = fullfile(mdir,dcatch);
end
fclose(fid);
xx = 1;