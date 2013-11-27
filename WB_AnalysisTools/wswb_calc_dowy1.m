function [DOWY1,RbDOWY1,RbStdDOWY1] = wswb_calc_dowy1(R_daily,Rcys,is_Rb,wsz,quant_val,st_plot)

% WSWB_CALC_WYDAY1(R_daily_cy,Rcys,is_Rb,wsz,quant_val,st_plot)) calculates the 
% first day of the water year (DOWY1) using the distribution of days of minimum Rb 
% for all valid data years
%
% INPUT
% R_daily		= daily runoff array [Ncys x docy]
% Rcys			= vector of calendar years that correspond to R_daily_cy rows
% is_Rb			= flag whether input runoff array is baseflow
% wsz			= size of averaging window [default = 15 days]
% st_plot		= optional info for plotting
%
%
% OUTPUT
% DOWY1			= [DOWY1med,DOWY1quant,DOWY1Oct1]
% RbDOWY1		= [RbDOWY1med, RbDOWY1quant,RbDOWY1Oct1];
% RbStdDOWY1	= [RbStdDOWY1med,RbStdDOWY1quant,RbStdDOWY1Oct1];
%
% TC Moran UC Berkely 2013

%% INITIALIZE
if nargin < 3, is_Rb = false; end	% default to total runoff, not baseflow
if nargin < 4, wsz = 15; end		% default to +-15 day averaging window
if nargin < 5, quant_val = 0.8; end % default quantile value
if nargin < 6, st_plot = []; end    % default to empty

%% CALCULATE BASEFLOW ARRAY
%  If R not input as baseflow Rb
if is_Rb
	Rb = R_daily;
else
	Rb = baseflow_filter2(R_daily_cy,Rcys);
end

% CALC DOWY1
%% 1. Fill nans and eliminate values < 0
Rbvec = daily2vec(Rb,Rcys);			% make vector from daily array, better for filtering
Rbvec = fillnans_interp(Rbvec);		% fill nans with interpolated values
Rbvec(Rbvec<0) = 0;					% no negative values (from interpolation)

%% 2. Smooth daily Rb values to eliminate ephemeral values and emphasize trends
RbvecFilt = filtfilt(ones(1,wsz)/wsz,1,Rbvec);	% zero-phase moving average filter
RbFilt = vec2daily(RbvecFilt,Rcys);             % reshape to [year x day] array
RbFilt(isnan(Rb)) = nan;                        % replace nans from input array
Nchk = sum(isnan(RbFilt),2)<30;                 % Allow less than 30 missing days of data per year
RbFilt = RbFilt(Nchk,:);
Rcys = Rcys(Nchk);

if isempty(RbFilt)  % return NaNs if RbFilt is empty
	DOWY1=[nan,nan,nan];RbDOWY1=[nan,nan,nan];RbStdDOWY1=[nan,nan,nan];
	return;
end

%% 3. Calculate first DOWY 
% October 1
DOWY1Oct1 = firstdayofmonth(10,2001);

% treat differently if min = 0 or if min > 0
[~,minRb] = nanmin(RbFilt,[],2);
if min(minRb)<5
	xx = 1;
end

for yy = 1:size(RbFilt,1)
	if nanmin(RbFilt(yy,:))>0	% if min Rb > 0, then use date of min Rb
		[~,minRb_doy(yy,1)] = nanmin(RbFilt(yy,:));
	else	% if min Rb == 0, then use date of min Rb after first non 0 date
		idx0 = find(RbFilt(yy,:)>0); 
		if isempty(idx0)
			minRb_doy(yy,1) = nan;	% *** if no Rb at all return a NaN
			continue
		end
		[~,minRb_doyAfterNon0] = nanmin(RbFilt(yy,idx0(1):end));
		minRb_doy(yy,1) = minRb_doyAfterNon0 + idx0(1)-1;
	end
end

% DOWY1med = median DOY with min Rb
DOWY1med = round(nanmedian(minRb_doy))+1;		% DOWY1 as median doy with min Rb

% DOWY1quant = DOY that precedes 'quant_val' fraction of min Rb days
quant_val = [1-quant_val,quant_val];
dowy1quant = round(quantile(minRb_doy,quant_val)); % DOWY1 as quantile doy with min Rb

DOWY1quant = dowy1quant(1);

%% 4. CALCULATE MEDIAN and STANDARD DEVIATION of Rb on DOWY1
% DOWY1med
RbDOWY1med = nanmean(Rb(:,DOWY1med));		% mean Rb on DOWY1med
if sum(~isnan(Rb(:,DOWY1med)))>3			% require at least 3 days data to calc stdev 
	RbStdDOWY1med = nanstd(Rb(:,DOWY1med)); % stdev of Rb on DOWY1med
else
	RbStdDOWY1med = nan;
end

% DOWY1quant
RbDOWY1quant = nanmean(Rb(:,DOWY1quant));		% mean Rb on DOWY1quant
if sum(~isnan(Rb(:,DOWY1quant)))>3				% require at least 3 days data to calc stdev 
	RbStdDOWY1quant = nanstd(Rb(:,DOWY1quant));	% stdev of Rb on DOWY1quant
else
	RbStdDOWY1quant = nan;
end

% DOWY1 October 1
RbDOWY1Oct1 = nanmean(Rb(:,DOWY1Oct1));			% mean Rb on DOWY1Oct1
if sum(~isnan(Rb(:,DOWY1Oct1)))>3				% require at least 3 days data to calc stdev 
	RbStdDOWY1Oct1 = nanstd(Rb(:,DOWY1Oct1));	% stdev of Rb on DOWY1Oct1
else
	RbStdDOWY1Oct1 = nan;
end

DOWY1 = [DOWY1med,DOWY1quant,DOWY1Oct1];
RbDOWY1 = [RbDOWY1med, RbDOWY1quant,RbDOWY1Oct1];
RbStdDOWY1 = [RbStdDOWY1med,RbStdDOWY1quant,RbStdDOWY1Oct1];

if isempty(st_plot), return, end    % Done if not plotting


%% PLOT (OPTIONAL)
% Precip data - only include same years as R data, smooth
P_daily = st_plot.P_daily;
Pcys = st_plot.Pcys;
Pchk = ismember(Pcys,Rcys);
P_daily = P_daily(Pchk,:);
Pnorm = nanmean(P_daily,1);
PnormFilt = filtfilt(ones(1,wsz)/wsz,1,Pnorm);

% Median Rb data, smoothed
RbNorm = nanmedian(Rb(Nchk,:),1);
RbFiltNorm = filtfilt(ones(1,wsz)/wsz,1,RbNorm);

% PET - This is CIMIS data from 2001 - 2010 (approx), not same years as P and Rb
pet_mo = st_plot.pet_mo;
pet_mo = nanmedian(pet_mo,1);
pet_d = pet_mo./30;
pet_d = [pet_d,pet_d(1)];

% PLOT
% hf = figure;
hf = figure('visible','off');
hold on, box on
% Smoothed P and Rb, log10 scale to emphasize low flows
plot(log10(PnormFilt),'b')
plot(log10(RbFiltNorm),'r')

doy = firstdayofmonth(1:13,2001);
plot(doy,log10(pet_d),'g')
legend('P','Rb','PET','Location','best')

% DOWY1 lines
yl = ylim;
line([DOWY1Oct1,DOWY1Oct1],yl,'Color','k')
line([DOWY1quant,DOWY1quant],yl,'Color','k','Linestyle','--')
line([DOWY1med,DOWY1med],yl,'Color','r','Linestyle','--')
line([dowy1quant(1),dowy1quant(2)],[log10(RbDOWY1med),log10(RbDOWY1med)],'Color','r','LineStyle','--')

% Title and axes
txt = [num2str(st_plot.id),': ',st_plot.ws_name];
title(txt)
doy = firstdayofmonth(1:12,2001);
mo = {'J','F','M','A','M','J','J','A','S','O','N','D'};
set(gca,'Xtick',doy,'XtickLabel',mo)
ylabel('log10(flux rate mm/day)')
xlim([1,366])
set(gca,'FontSize',14,'fontWeight','bold')
set(findall(hf,'type','text'),'fontSize',14,'fontWeight','bold')

% save
figpath = fullfile(st_plot.dir_ws,'DATA_PRODUCTS','DAILY_MEAN_FLUXES_DOWY1_2');
saveas(hf,[figpath,'.fig'])
saveas(hf,[figpath,'.png'])
close(hf)

% HISTOGRAM
% hf = figure;
hf = figure('visible','off');
hist(minRb_doy)
yl = ylim;
line([DOWY1Oct1,DOWY1Oct1],yl,'Color','k')
line([DOWY1quant,DOWY1quant],yl,'Color','k','Linestyle','--')
line([DOWY1med,DOWY1med],yl,'Color','r','Linestyle','--')
set(gca,'Xtick',doy,'XtickLabel',mo)
ylabel(['Count (N=',num2str(length(minRb_doy)),')'])
title(['DOY min Rb: ',st_plot.ws_name,', ',num2str(st_plot.id),])
set(gca,'FontSize',14,'fontWeight','bold')
set(findall(hf,'type','text'),'fontSize',14,'fontWeight','bold')

% save
figpath = fullfile(st_plot.dir_ws,'DATA_PRODUCTS','HIST_DOY_MIN_Rb');
saveas(hf,[figpath,'.fig'])
saveas(hf,[figpath,'.png'])
close(hf)

xx = 1;
