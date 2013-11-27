function [dwbFilt,filtChks] = filter_wb_v1(dir_catch,st_filt)

% FILTER_WB_V1(dir_catch) filters yearly water balance data for the
% catchment specified by dir_catch
%
% FILTERS
% NR < Nmin     Neglect years with insufficient days of R data
% R < Rmin      Neglect dry years with low R
% P-R < ETmin   Neglect improbably low values of ET
% P-R > ETmax   Neglect improbably high values of ET; ETmax = max(PET) + dET
%
% INPUTS
% dir_catch     = absolute path to catchment directory
% st_filt       = structure with filter values
%                 st_filt.Nmin
%                 st_filt.Rmin
%                 st_filt.ETmin
%                 st_filt.dET
%
% OUTPUTS
% dwbFilt  = filtered yearly water balance data array
% saved text file 'FILTERED_PRDIFF_PRISMp_GAGEr.txt'
%
% TC Moran UC Berekeley 2013

%% INITIALIZE
if nargin < 1, dir_catch = uigetdir; end
% DEFAULT FILTER VALUES
if nargin < 2
    Nmin  = 355;    % # days
    Rmin  = 100;    % mm
    ETmin = 200;    % mm
    dET   = 0;      % mm
else
    Nmin = st_filt.Nmin;  Rmin = st_filt.Rmin; 
    ETmin= st_filt.ETmin; dET  = st_filt.dET;
end
% File names
fname_filtwb = 'FILTERED_PRDIFF_PRISMp_GAGEr.txt';
path_filtwb  = fullfile(dir_catch,'DATA_PRODUCTS',fname_filtwb);
fname_filtchk= 'Filter_Checks.txt';
path_filtchk = fullfile(dir_catch,'DATA_PRODUCTS',fname_filtchk);

% directories
dparts = dirparts(dir_catch);
dir_catch_rel = dparts{end};

dir_wb = fullfile(dir_catch,'DATA_PRODUCTS');
dir_pet = fullfile(dir_catch,'GRID_PRISM','GRID_PRISM_HPET');


%% IMPORT WB AND PET DATA
% WB data
if isdir(dir_wb)
    try
        dwb = dlmread(fullfile(dir_wb,'PRODUCT_PRDIFF_PRISMp_GAGEr.txt'),'\t',1,0);
    catch
        display(['No WB data for ',dir_catch_rel]), return
    end
else
    display(['No WB data for ',dir_catch_rel]), return
end
% import PET estimate
if isdir(dir_pet)
    dpet = dlmread(fullfile(dir_pet,'GRID_DATA_WY_MONTHLY_WEIGHTED_MEAN.txt'),'\t',2,0);
    pet_lim = max(dpet(:,end));
else
    display(['No WB data for ',dir_catch_rel]), return
end

%% FILTER 1: MIN R DAYS
Nchk = dwb(:,5) >= Nmin;

%% FILTER 2: VERY DRY YEARS
Rchk = dwb(:,4) > Rmin;

%% FILTER 3: VERY LOW ET
etchk = dwb(:,2) > ETmin;

%% FILTER 4: VERY HIGH ET
ETmax = pet_lim+dET;
ETchk = dwb(:,2) < ETmax;

%% CONSOLIDATE FILTER RESULTS
filtChks = [Nchk,Rchk,etchk,ETchk];
CHK = logical(prod(double(filtChks),2));
dwbFilt = dwb(CHK,:);

%% SAVE TEXT FILES
% Filtered WB 
hdr_filtwb = ['WY,P-R(mm),P(mm),R(mm),R_numdatadays'];
dlmwrite(path_filtwb,hdr_filtwb,'delimiter','')
dlmwrite(path_filtwb,dwbFilt,'-append','delimiter','\t')

% Filter Info and Results
hdr_filtchk = ['NR>',num2str(Nmin),',R>',num2str(Rmin),',P-R>',num2str(ETmin),',P-R<maxPET+',num2str(dET)];
dlmwrite(path_filtchk,hdr_filtchk,'delimiter','')
dlmwrite(path_filtchk,double(filtChks),'-append','delimiter','\t')



