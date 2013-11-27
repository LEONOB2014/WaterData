function [d_day_wy,d_wys] = cy2wy_daily(d_day_cy, d_cys, day1_wy)

if nargin < 3
	day1_wy = 274; % default first day of water year to Oct 1 for non-leap year
end %

d1 = day1_wy;

dcy = d_day_cy;

dwy(:,1:(366-d1+1)) = dcy(1:end-1,d1:end);
dwy(:,(366-d1+2):366) = dcy(2:end,1:(d1-1));

% water year always defined as calendar year that water year ends
d_day_wy = dwy;
if day1_wy > 1		
	d_wys = d_cys(2:end);
else	% special case that wy = cy
	d_wys = d_cys;
end