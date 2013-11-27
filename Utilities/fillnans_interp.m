function y = fillnans_interp(y,x)

% FILLNANS_INTERP(y,x) replaces NaNs in vector y with interpolated values
%
% INPUTS
% y		= observed values, dependent variable
% x		= x-axis values, independent variable
%
% OUTPUTS
% Y		= filled output vector
%
% TC Moran UC Berkeley 2013

%% INITIALIZE
if nargin < 2, x = 1:length(y); end

%% STRETCH Y AND X OVER NAN VALUES
nidx= find(isnan(y));	% nan indexes
idx = find(~isnan(y));	% non-nan indexes
yy = y(idx);
xx = x(idx);

%% INTERPOLATE ACROSS NAN INDICES
for nn = 1:length(nidx)
	yi = interp1(xx,yy,nidx(nn),'spline');
	y(nidx(nn)) = yi;
end
xx = 1;
