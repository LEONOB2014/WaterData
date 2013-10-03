function setup_huc_boundary(dir_master)

% SETUP_HUC_BOUNDARY creates a directory with HUC shapefiles in each HUC
% directory found in dir_master
%
% INPUTS
% dir_master = absolute path to directory containing HUC subdirectories
%
% OUTPUTS
% saved files in HUC subdirectories
% TC Moran UC Berkeley 2011

%% SETUP
if nargin < 1
   dir_master = uigetdir; 
end

%%
dir_orig = cd(dir_master);
hucbound_name = 'BOUNDARY_HUC';
% HUC dir names
dnames = get_dir_names; % all dirs
str1{1} = 'HUC';
dir_hucs = find_full_string(dnames,str1);

% HUC boundary data
% *** DATA PATH DEPENDENCY ***
dir_hucdata = '/Users/tcmoran/Desktop/Catchment Analysis 2011/CA Water Boundaries/CA HUCs Etc/hydrologic_units';
hucdata_fnames = get_file_names(dir_hucdata);

nhucs = length(dir_hucs); % number of huc directories in master directory
for nn = 1:nhucs
    % get this HUC directory and number from HUC directory list
    dir_thishuc = dir_hucs{nn};
    huc_num_str = dir_thishuc(4:end);
    dir_last = cd(dir_thishuc);
    % make directory for boundary data
    if ~isdir(hucbound_name)
       mkdir(hucbound_name)
    end
    cd(hucbound_name)
    % get shape file name for this HUC
    str2{1} = huc_num_str; str2{2} = '.shp'; 
    % Polygon Shapefile
    str2{3} = '_a_'; % polygon file
    fname_shpP = find_full_string(hucdata_fnames,str2);
    if isempty(fname_shpP) % move on if no shape file for this HUC
        cd(dir_master)
        continue 
    end
    fname_shpP = fullfile(dir_hucdata,fname_shpP{1});
    % load shapefile data into structure
    st_hucP = shaperead(fname_shpP);
    save('ST_HUC_BOUNDARY_POLYGON.mat','st_hucP')
    % Line Shapefile
    str2{3} = '_l_';
    fname_shpL = find_full_string(hucdata_fnames,str2);
    fname_shpL = fullfile(dir_hucdata,fname_shpL{1});
    % load shapefile data into structure
    st_hucL = shaperead(fname_shpL);
    save('ST_HUC_BOUNDARY_LINE.mat','st_hucL')
    clear st_hucP st_hucL
    cd(dir_master)
    togo = nhucs - nn
end
