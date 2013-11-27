function eto = calc_eto_v1(dir_catch)

% CALC_ETo_V1(dir_catch) calculates ETo for the catchment 'dir_catch'.
% Run 'filter_wb_v1' first.
% Previous similar functions called 'estimate_et0_v2' and 'estimate_et0'
%
% INPUTS
% dir_catch = absolute path to catchment directory
%
% OUTPUTS
% eto   = ETo: mean ET for wet conditions (mm)
% save figure and text file with ETo
%
% TC Moran UC Berkeley 2013

%% INITIALIZE
if nargin < 1, dir_catch = uigetdir; end

% file names and directories
dir_wb = fullfile(dir_catch,'DATA_PRODUCTS');
fname_wbfilt    = 'FILTERED_PRDIFF_PRISMp_GAGEr.txt';
path_wbfilt     = fullfile(dir_wb,fname_wbfilt);
fname_filtchk   = 'Filter_Checks.txt';
path_filtchk    = fullfile(dir_wb,fname_filtchk);

% files to save
fname_eto_txt = 'ETo_FiltVals.txt';
path_eto_txt = fullfile(dir_wb,fname_eto_txt);

%% CHECK FOR FILTERED DATA
fname_chk = get_file_names2(dir_wb,fname_wbfilt);
if isempty(fname_chk)   % first run filter checks if not already done
    filter_wb_v1(dir_catch)
end

%% IMPORT FILTERED DATA
dwb  = dlmread(path_wbfilt,'\t',1,0);   % Filtered WB data
fid = fopen(path_filtchk);
fhdr = textscan(fid,'%s %s %s %s',1,'Delimiter',',');
fclose(fid);
Rmin = str2num(fhdr{2}{1}(3:end));
ETmin = str2num(fhdr{3}{1}(5:end));
ETmax = str2num(fhdr{4}{1}(12:end));

%% CALCULATE ETo
%  ETo is simply the mean of the filtered values of P-R
eto = round(mean(dwb(:,2)));

%% SAVE TEXT FILE
txt_hdr = ['ETo, Rmin, ETmin, ETmax=PET+'];
ETo = [eto,Rmin,ETmin,ETmax];
dlmwrite(path_eto_txt,txt_hdr,'')
dlmwrite(path_eto_txt,ETo,'-append','Delimiter','\t')
