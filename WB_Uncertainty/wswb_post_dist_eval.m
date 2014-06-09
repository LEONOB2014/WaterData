function st = wswb_post_dist_eval(Pdist,plotTF)

% WSWB_POST_DIST_EVAL(Pdist) does a non-parametric evaluation of the
% distribution Pdist, e.g. a posterior distribution from an MCMC run, and
% ouputs summary statistics. Pdist may be multimodal.

%% INITIALIZE
if nargin < 2, plotTF = false; end

%% KERNEL DENSITY ESTIMATE
[~,Pd,x]=kde(Pdist);
dx = x(2)-x(1);
xmax = max(Pdist); xmin = min(Pdist);

%% FIND MAXIMA
[peakval,peakidx] = peakfind(Pd);
[maxval,idx] = max(peakval);
maxidx = peakidx(idx);

%% FWHM
% determine FWHM values for each side of peaks
halfmax = maxval/2;
Pd1 = Pd(1:maxidx); x1 = x(1:maxidx);
Pd2 = Pd(maxidx:end); x2 = x(maxidx:end);
xmode = x(maxidx);

[~,ix1] = find_nearest(Pd1,halfmax);
fwhm1 = x1(ix1);		% lower val of FWHM
[~,ix2] = find_nearest(Pd2,halfmax);
fwhm2 = x2(ix2);		% upper val of FWHM

FWHM = fwhm2-fwhm1;		% width of FWHM
% Integral of curve between FWHM points is relative prob that value falls
% within that range
Pfwhm = sum(Pd1(ix1:end))*dx + sum(Pd2(2:ix2))*dx;

%% QUANTILES
quantvals = [0.5,0.25];
df = 0.001;
N = ceil(1/df);
Pd1 = Pd(1:maxidx);		x1 = x(1:maxidx);
Pd2 = Pd(maxidx:end);	x2 = x(maxidx:end);
for ii = 1:N
	maxfrac = 1-df*ii;
	Pfrac = maxval*maxfrac;
	
	[~,ix1] = find_nearest(Pd1,Pfrac);
	[~,ix2] = find_nearest(Pd2,Pfrac);
	pQ(ii) = sum(Pd1(ix1:end))*dx + sum(Pd2(2:ix2))*dx;
	pQlo(ii) = x1(ix1);		% lower val of 50 quantile
	pQhi(ii) = x2(ix2);		% upper val of 50 quantile
	pQspan(ii) = pQhi(ii)-pQlo(ii);
	pQval(ii) = Pfrac;
end
% % *** Need good method to deal with multimodal distribs ****
[pQspan,ix] = sort(pQspan);
pQ = pQ(ix); pQlo = pQlo(ix); pQhi = pQhi(ix); pQval = pQval(ix);
% 50 percentile
[~,jj] = find_nearest(pQ,quantvals(1));
p50lo = pQlo(jj); p50hi = pQhi(jj); p50span = pQspan(jj); p50val = pQval(jj); 
% 25 percentile
[~,jj] = find_nearest(pQ,quantvals(2));
p25lo = pQlo(jj); p25hi = pQhi(jj); p25span = pQspan(jj); p25val = pQval(jj); 


%% OUTPUT
% KDE
st.KDE.Pd = Pd;
st.KDE.x  = x;
st.KDE.dx = dx;

% MODE
st.mode.val = xmode;
st.mode.P	= maxval;
% FWHM
st.FWHM.lower = fwhm1;
st.FWHM.upper = fwhm2;
st.FWHM.span  = FWHM;
st.FWHM.prob  = Pfwhm;
% QUANTILES
% 50
st.quant.p50.lower = p50lo;
st.quant.p50.upper = p50hi;
st.quant.p50.span = p50span;
st.quant.p50.prob = p50val;
% 25
st.quant.p25.lower = p25lo;
st.quant.p25.upper = p25hi;
st.quant.p25.span = p25span;
st.quant.p25.prob = p25val;

%% PLOT
if ~plotTF, return, end

hf = figure;
histnorm(Pdist,100), plot(x,Pd,'r')
scatter(p50lo,p50val,'om','filled'), scatter(p50hi,p50val,'om','filled')
scatter(p25lo,p25val,'or','filled'), scatter(p25hi,p25val,'or','filled')
xx = 1;
