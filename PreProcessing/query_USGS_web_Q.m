function status = query_USGS_web_Q(site_id,dir_save,filename)

% QUERY_USGS_WEB_Q(site_id) submits an online query for USGS streamflow
% data
%
% INPUTS
% site_id   = USGS streamflow site number (string)
% dir_save  = directory to save retrieved data
% filename  = filename for retrieved data
%
% TC Moran UC Berkeley 2012

%% INITIALIZE
if nargin < 2, dir_save = pwd; end
if nargin < 3, filename = 'Qdata_USGS_web.rdb'; end

dir_orig = cd(dir_save);

%% MAKE AND SUBMIT QUERY
url_str = ['http://waterservices.usgs.gov/nwis/dv?format=rdb&sites=',site_id,'&period=P10000W&parameterCd=00060'];

% Try URLWRITE up to 10 times
status = false; ii = 1;
while ii < 10 && ~status
    [~, status] = urlwrite(url_str,filename);
    ii = ii+1;
end
