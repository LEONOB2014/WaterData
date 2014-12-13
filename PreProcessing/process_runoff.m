function stQcfs = process_runoff(site_id, dir_data, st_params, forceTF)

% PROCESS_RUNOFF(site_id, dir_data) processes USGS runoff data and saves it
% in directory dir_data
%
% INPUTS
% site_id   = USGS streamflow site id (string)
% dir_data  = absolute path to directory where data products will be saved
%             e.g. [catchment dir]/GAGE_RUNOFF
% st_params = structure with processing parameters
%             e.g. st_params.wy_month1 = 10 specifies Oct as 1st mo of WY
%
% OUTPUTS
% misc saved files
%
% TC Moran UC Berkeley 2012

%% INITIALIZE
if nargin < 2, dir_data = pwd; end % default to current dir if no destination specified
if nargin < 3
    % specify the calendar day of the first day of the water year (got it?)
    wy_month1 = 10;
    wy_day1 = firstdayofmonth(wy_month1);
else
    wy_day1 = st_params.wy_day1;
    wy_month1 = st_params.wy_month1;
end
if nargin < 4, forceTF=false; end
dir_orig = cd(dir_data);

fnameQ = 'Qdata_USGS_web.rdb'; % filename for data retrieved from USGS website

%% GET DISCHARGE DATA VIA WEB QUERY

% first check if file already exists
fchk = isfilename(fnameQ,dir_data);
if ~fchk || forceTF
    status = query_USGS_web_Q(site_id,dir_data,fnameQ);  % this saves the file 'Qdata_USGS_web.rdb' in dir_data
    if ~status % if no data retrieved from USGS website
       stQcfs = struct; 
       cd(dir_orig)
       return
    end
end

Qcfs = import_USGS_web_Q(fnameQ,dir_data);     % Qcfs = [YYYY,MM,DD,DOY,Mean Daily Q (cfs)]

%% CONVERT DATA TO OTHER ARRAY SHAPES

% [Year x Day]
[Qcfs_cy_doy, cys] = reshape_ymddoy2cydaily(Qcfs); % % [Calendar year x day of year] mean daily Q (cfs)
[Qcfs_wy_dowy,wys] = cy2wy_daily(Qcfs_cy_doy, cys, wy_day1); % [Water year x day of water year] mean daily Q (cfs)

% [Year x Month]
Qcfs_cy_mo = reshape_ymddoy2cy_monthly(Qcfs); % [CY x Month] mean monthly Q (cfs)
[Qcfs_wy_mo,d_wys] = cy2wy_monthly(Qcfs_cy_mo, cys, wy_month1); % [WY x Month] mean monthly Q (cfs)

%% MAKE OUTPUT STRUCTURE
stQcfs.cyears = cys;    % Calendar Year data
stQcfs.Qcfs_cy_doy = Qcfs_cy_doy;
stQcfs.Qcfs_wy_dowy= Qcfs_wy_dowy;
stQcfs.wyears = wys;    % Water Year data
stQcfs.Qcfs_cy_mo  = Qcfs_cy_mo;
stQcfs.Qcfs_wy_mo  = Qcfs_wy_mo;

cd(dir_orig)