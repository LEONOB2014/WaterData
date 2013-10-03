function plot_huc_boundary2(dir_master)

% PLOT_HUC_BOUNDARY(dir_master) makes plots for each HUC
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

dir_orig = cd(dir_master);
hucbound_dirname = 'BOUNDARY_HUC';
hucbound_dataname = 'ST_HUC8_BOUND.mat';

% HUC dir names
dnames = get_dir_names; % all dirs
str1{1} = 'HUC';
dir_hucs = find_full_string(dnames,str1);

%% LOAD CA STATE SHAPE
% *** PATH DEPENDENCY ***
ca_st_path = '/Users/tcmoran/Desktop/Catchment Analysis 2011/CA Shape File US Census/CATCHMENT_CA/boundary/ST_BOUNDARY_DATA.mat';
% loads CA boundary into st_boundary
load(ca_st_path)
xCA = st_boundary.Lon_degE;
yCA = st_boundary.Lat_degN;

%% PREPROCESS HUC8 BOUNDARIES
get_huc8_bounds(dir_master)

%% CYCLE THROUGH HUC DIRS
nhucs = length(dir_hucs); % number of huc directories in master directory
for nn = 1:nhucs
    %% LOAD BOUNDARY DATA STRUCTURE
    % get this HUC directory and number from HUC directory list
    dir_thishuc = dir_hucs{nn};
    huc_num_str = dir_thishuc(4:end);
    dir_last = cd(dir_thishuc);
    cd(hucbound_dirname)
    fnames = get_file_names;
    % skip if boundary structure isn't here
    if isempty(fnames) || ~ismember(hucbound_dataname,fnames)
        cd(dir_master)
        continue
    end
    load(hucbound_dataname)
%     load('ST_HUC_BOUNDARY_POLYGON.mat')
    %% PLOTS
%     n = size(st_hucL,1);
%     x1 = []; y1 = [];
%     x2 = []; y2 = [];
%     for ii = 1:n
%         huclev = st_hucL(ii).HU_LEVEL;
%         % huc levels 1,2,3,4 define outer boundary
%         % huc levels 5,6+ are watershed scale
%         if huclev == 1 || huclev == 2 || huclev == 3 || huclev == 4
%             x1 = [x1,st_hucL(ii).X];
%             y1 = [y1,st_hucL(ii).Y];
%         elseif huclev == 5 || huclev == 6 || huclev == 7
%             x2 = [x2,st_hucL(ii).X];
%             y2 = [y2,st_hucL(ii).Y];
%         end
%     end
    
    X = ST_HUC8_BOUND.boundary.X;
    Y = ST_HUC8_BOUND.boundary.Y;
    
    
    % HUC8
    hf1 = figure; hold on
    plot(X,Y,'b','LineWidth',1)
%     plot(x2,y2,'k','LineWidth',1)
    xlabel('Lon (deg E)')
    ylabel('Lat (deg N)')
    title(['HUC ',huc_num_str])
    box on
    saveas(hf1,'huc_subcatch.fig')
    close(hf1)
    
    % CA with HUC
    hf2 = figure; hold on
    plot(xCA,yCA,'k','LineWidth',1)
    plot(X,Y,'b','LineWidth',2)
    xlabel('Lon (deg E)')
    ylabel('Lat (deg N)')
    title(['HUC ',huc_num_str])
    box on
    saveas(hf2,'ca_huc.fig')
    close(hf2)
    
    cd(dir_master)
    togo = nhucs - nn
end

cd(dir_orig)