function [d_mo, d_yrs] = reshape_ymddoy2cy_monthly(d_ymd, unit_factor)

% DCDATA_MONTHLY(d_ymd) reshapes the input data array d_ymd into annual
% rows and monthly total columns
% 
% INPUTS
% d_ymd = [yyyy, mm, dd, doy, data] array
%
% OUTPUTS
% d_mo  = [Year x Month(1:12)] mean monthly value
% d_yrs = [yyyy] rows
%
% T C Moran UC Berkeley 2011

if nargin < 2
   unit_factor = 24*3600; % use seconds to day unit convert as default 
end

d = d_ymd;
yrs = unique(d(:,1));
num_yrs = length(yrs);

for yy = 1:num_yrs
    yr = yrs(yy);
    iyr = d(:,1)==yr;
    dyr = d(iyr,:);
    for mm = 1:12
        imo = dyr(:,2) == mm;
        dmo = dyr(imo,:);
        mdays = sum(imo);
        D(yy,mm) = nanmean(dmo(:,5)); % returns the mean value for the month
%         D(yy,mm) = nanmean(dmo(:,5))*unit_factor*mdays;
        clear dmo imo
    end
%     D(yy,13) = nanmean(D(yy,1:12));
    clear dyr
end 

d_mo = D;
d_yrs = yrs;