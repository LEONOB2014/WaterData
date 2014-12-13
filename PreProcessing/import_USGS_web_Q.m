function Qcfs = import_USGS_web_Q(fname_Q,dir_data)

%% INITIALIZE
if nargin < 2, dir_data = pwd; end

% file format
nhdr = 2;
format_str = ['%*s %*s %s %s %s'];

%% IMPORT USGS Q DATA
fid = fopen(fname_Q);
% Note that CommentStyle is a bit wonky to account for unknown number of
% comment header lines
ceQ = textscan(fid,format_str,'CommentStyle',{'#','10s'},'HeaderLines',nhdr);
fclose(fid);

%% CONVERT STREAMFLOW TO NUMBERS
for dd = 1:length(ceQ{2})
    q = str2num(ceQ{2}{dd});
    if ~isempty(q)
        Q(dd,1) = q;
    else
        Q(dd,1) = NaN;
    end
end

% Exclude days that don't have valid Q data values
qnan = ~isnan(Q);
Q = Q(qnan);
ncols = size(ceQ,2);
for cc = 1:ncols
    ceQ{cc} = ceQ{cc}(qnan);
end
    
%% CONVERT DATES
date_str = ceQ{1};
date_number = datenum(date_str);
[Y,M,D] = datevec(date_number);
doy = datenum2doy(date_number);     % also day of year (doy)

Qcfs(:,1:3) = [Y,M,D];
Qcfs(:,4) = doy;
Qcfs(:,5) = Q;
% Don't use the data qualification codes for now

xx = 1;