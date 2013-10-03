function calc_ws_products2(parent_dir, prod_case)

% CALC_WS_PRODUCTS(parent_dir, prod_case) 
% calculates synthesized data products from various data
% sources for the site directories located within parent_dir
%
% INPUTS
% parent_dir    = absolute path to directory with site subdirectories
% prod_case     = string to identify which product to calculate
%
% OUTPUTS
% products saved in 'DATA_PRODUCTS' directory
%
% TC Moran UC Berkeley 2011

%% DEFAULTS AND DIRECTORIES
if nargin < 1
    parent_dir = uigetdir;
end
% default analysis case = weighted mean
if nargin < 2
    prod_case = 'GRIDPRECIP-GAGERUNOFF';
else
    prod_case = upper(prod_case);
end

dir_orig = cd(parent_dir);
pdir_names = get_dir_names;

% get list of catchment data directories
str{1} = 'CATCHMENT';
dir_catch = find_full_string(pdir_names, str);

% data products directory name
dir_prod = 'DATA_PRODUCTS';

%% GET LIST OF MANIPULATED CATCHMENTS
fname_manip = 'ManipulatedCatchments.txt';
path_manip = fullfile('..',fname_manip);
fname = get_file_names2('..',fname_manip);
if ~isempty(fname)
    manip_site_lastyear = dlmread(path_manip,'\t',1,0);
    manip_site = cellstr(num2str(manip_site_lastyear(:,1)));
    manip_lastyear = manip_site_lastyear(:,2);
else
    manip_site = {};
    manip_lastyear = [];
end


%% CYCLE THROUGH CATCHMENT DIRECTORIES
num_dir = length(dir_catch);

for dd = 1:num_dir
    catch_dir = dir_catch{dd};
    catch_id = catch_dir(30:37);
    catch_abs = fullfile(parent_dir,catch_dir);
%     this_dir = dir_catch{dd};
%     last_dir = cd(dir_catch{dd});
    % make products directory
    if ~isdir(fullfile(catch_abs,dir_prod))
        mkdir(fullfile(catch_abs,dir_prod))
    end %if
        
    %% COMPARE AGAINST LIST OF MANIP CATCH
    mchk = strcmp(catch_id,manip_site);
    if max(mchk)==1
        lastyear = manip_lastyear(mchk);
    else
        lastyear = 9999;
    end
    
    %% SWITCH AMONG DATA PRODUCT OPTIONS
    %  call functions for each analysis type
    switch prod_case
        case 'GRIDPRECIP-GAGERUNOFF'
%             catch_dir = pwd;
            calc_gridprecip_gagerunoff3(catch_abs,dir_prod,lastyear);
        
    end %switch
    % back to parent dir
end %for dd

cd(dir_orig)