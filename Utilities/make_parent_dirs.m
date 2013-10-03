function make_parent_dirs(master_site_file, dir_master)

% MAKE_PARENT_DIRS(master_site_file) creates site_info files and
% directories for each of the catchment parents numbers (e.g. HUCs) in a
% master site file.
%
% INPUTS
% master_site_file = absolute path to text file with same format as site_info files
%
% OUTPUTS
% directories for each parent number, with a site_info file for each
%
% TC Moran UC Berkeley, 2011

%% INITIALIZE
if nargin < 1
    [fname, fdir] = uigetfile('*.txt');
    master_site_file = fullfile(fdir,fname);
end
mfile = master_site_file; % shorthand
if nargin < 2
    dir_master = uigetdir;
end
dir_orig = cd(dir_master);


%% IMPORT CATCHMENT INFO
st_site_info = import_site_info(mfile);
% convert site info struct to cell
ce_site_info = squeeze(struct2cell(st_site_info));
% parent cell vector
ce_parent = ce_site_info(3,:);
% convert parent cells to matrix
mat_parent = cell2mat(ce_parent);
% get unique parent codes
parent_list = unique(mat_parent)';

% replace any blank cells or NaN cells with -9999 as a dummy variable
for ii = 1:length(ce_parent)
    this_parent = ce_parent{ii};
    if ~isempty(this_parent)
        fullmat_parent(ii) = this_parent; % 
    else
        fullmat_parent(ii) = -9999;
    end
end

% Make cell array containing structs for each catch that belongs to parent
NP = length(parent_list);
for nn = 1:NP
    this_parent = parent_list(nn);
    idx = find(fullmat_parent == this_parent);
    stp = st_site_info(idx);
    cep = ce_site_info(:,idx);
    ceP{nn,1} = this_parent;
    ceP{nn,2} = cep;    
end
% also get sites with no parent
idx = find(fullmat_parent == -9999);

% Make a directory for each Parent
parent_type = 'HUC';
for pp = 1:size(ceP,1)
    this_pnum = ceP{pp,1};
    this_cep = ceP{pp,2};
    pdir_name = [parent_type,num2str(this_pnum)];
    if ~isdir(pdir_name)
        mkdir(pdir_name)
    end
    dir_last = cd(pdir_name);
    write_site_info_file(this_cep');
    cd(dir_last)
end

xx = 1; % debugging line
