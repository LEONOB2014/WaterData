function [d_cy_doy, d_cys] = reshape_ymddoy2cydaily(d_ymddD)

% RESHAPE_YMDDOY2CYDAILY reshapes input array d_ymddoyD to output array d_day
%
% INPUTS
% d_ymddD   = [yyyy, mm, dd, doy, Data] x yearly rows
% 
% OUTPUTS
% d_day     = [Year x doy] daily data array
% d_yrs     = column of years corresponding to d_day years
%
% TC Moran UC Berkeley 2012

d = d_ymddD;
yrs = unique(d(:,1));
num_yrs = length(yrs);

% preallocate NaN array
D = nan(num_yrs,366);

for yy = 1:num_yrs
    yr = yrs(yy);
    iyr = d(:,1)==yr;
    dyr = d(iyr,:);
    Ddoy = dyr(:,4);
    D(yy,Ddoy) = dyr(:,5);
    clear dyr Ddoy
end 

d_cy_doy = D;
d_cys = yrs;
