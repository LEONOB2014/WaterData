function [SlopeMean,SlopeEachYear,st_uncert] = wswb_calc_mean_recession(Rb,wyday1)

% WSWB_CALC_MEAN_RECESSION(Rb,wyday1) estimates the baseflow recession
% slope for the 2 month interval surrounding the first day of the water
% year
%
% INPUTS
% Rb	= daily baseflow runoff [Nyears x 366]
% wyday1= calendar day of first day of water year
%
% OUTPUTS
% SlopeMean		= recession slope calculated for mean log(Rb) vs t for all years
% SlopeR2chk	= recession slope calculated as mean of slopes for
%					individual years that are missing no data and with R2 >
%					some threshold (e.g. 0.9). Estimates by these two
%					methods tend to be fairly similar but SlopeR2chk has
%					the advantage of also offering a measure of the spread
%					around the mean (st_uncert.R2chk.slope_std)
% st_uncert		= structure with uncertainty metrics
%
% TC Moran UC Berkeley 2013

%% INITIALIZE
R2min = 0.8;
Ndays = 30;		% number of days before DOWY1 to include in recession analysis
if wyday1-Ndays > 1		% typical 
	days = wyday1-Ndays:wyday1-1;
else					% if wyday1 is in Jan then look forward - likely arbitrary for these early dates
	days = wyday1:wyday1+Ndays;
end
Rb = Rb(:,days);

% Rb = Rb(:,wyday1-Ndays:wyday1+Ndays);

x = 1:size(Rb,2);
RbMean = nanmean(Rb,1);
RbMeanLog = log(RbMean);

%% FIT LINE TO MEAN LOG Rb
[p,S] = polyfit(x,RbMeanLog,1);
SlopeMean = p(1);		% slope of fit

%% UNCERTAINTY ANALYSIS
[y,delta] = polyval(p,x,S);		% evaluate fit
R2m = rsquare(RbMeanLog,y);

st_uncert.mean.R2 = R2m;

% Individual years
RbLog = log(Rb);
ii = 1; R2 = []; pslope = [];
for yy = 1:size(Rb,1)
	rblog = RbLog(yy,:);
	if sum(isnan(rblog))>0 || sum(isinf(rblog))>0, continue, end;	% skip years with any missing values
	[~,pv] = corrcoef(x,rblog);
	pval(ii) = pv(2);
	p = polyfit(x,rblog,1);
	pslope(ii) = p(1);
	y = polyval(p,x);
	R2(ii) = rsquare(rblog,y);
	ii = ii+1;
end
R2chk = R2 >= R2min;
SlopeChk = pslope < 0;	% only want receding behavior
Chk = logical(R2chk.*SlopeChk);
SlopeEachYear = mean(pslope(Chk));

st_uncert.EachYear.meanR2 = mean(R2(Chk));
st_uncert.EachYear.slope_std = std(pslope(Chk));
st_uncert.EachYear.slope = SlopeEachYear;
st_uncert.EachYear.Nyears = sum(Chk);

xx = 1;