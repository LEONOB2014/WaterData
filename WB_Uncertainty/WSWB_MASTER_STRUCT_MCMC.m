function st_master = WSWB_MASTER_STRUCT_MCMC(st_master)

% WSWB_MASTER_STRUCT_MCMC(st_master) incorporates MCMC parameter estimation
% information into the st_master structure.
%
% **** FIRST RUN PYMC 'mcmc_run_fit_list.py' to perform generate posterior
% distribution data for parameter estimates
%
% TC Moran UC Berkeley, 2014

%% INITIALIZE
mdir = WB_PARAMS('dir_master');
NC = length(st_master);

%% CYCLE THROUGH WS
Nstart = 1;
for cc = Nstart:NC
	st = st_master(cc);
	
	%% POSTERIOR DISTRIBUTION DATA
	st = get_mcmc_post(st,mdir);
	
	%% BEST FIT FOR DISTRIBUTION CLASSES
	st = fit_mcmc_post(st);
	
	%% NON-PARAMETRIC DISTRIBUTION PROPERTIES (MODE, QUANTILES, ETC)
	st = calc_post_props(st,mdir);
	
	stm(cc) = st;
	
	display([num2str(100*cc/NC),'% done'])
end
st_master = stm;

xx = 1;


%% SUBFUNCTIONS
function st = get_mcmc_post(st,mdir)	% IMPORT MCMC POSTERIOR DISTRIB DATA
fnames = {'post_a.csv','post_b.csv','post_S.csv'};
cdir = st.DIR;
dir_mcmc = fullfile(mdir,cdir,'DATA_PRODUCTS','PR_PARAM_FIT');
for dd = 1:length(fnames)
	fname = fnames{dd};
	D = dlmread(fullfile(dir_mcmc,fname));
	st.PARAMFIT.pymc.(fname(1:end-4)).data = D';
end

function st = fit_mcmc_post(st)			% FIT DISTRIBUTIONS
ParamTypes = fieldnames(st.PARAMFIT.pymc);
FitTypes = {'Normal','GeneralizedExtremeValue','ExtremeValue','Logistic'};
for pp = 1:length(ParamTypes)
	D = st.PARAMFIT.pymc.(ParamTypes{pp}).data;
	for ff = 1:length(FitTypes)
		pd(ff) = fitdist(D,FitTypes{ff});
		negloglik(ff) = pd(ff).negloglik;
	end
	[~,idx] = min(negloglik);
	% Default to Normal distrib if other best fit is within 0.2%
	if idx ~= 1 && abs((negloglik(1)-negloglik(idx))/negloglik(idx))<0.002
		idx = 1;
	end
	st.PARAMFIT.pymc.(ParamTypes{pp}).dist_fit = pd(idx);
end

function st = calc_post_props(st,mdir)		% NON-PARAMETRIC DISTRIBUTION PROPERTIES (MODE, QUANTILES, ETC)
ParamTypes = fieldnames(st.PARAMFIT.pymc);
dir_plot = fullfile(mdir,st.DIR,'DATA_PRODUCTS','PR_PARAM_FIT');
fname_plot = 'MCMC_POST_';
warning('off','all')
for pp = 1:length(ParamTypes)
	ptype = ParamTypes{pp};
	Pdist = st.PARAMFIT.pymc.(ptype).data;
	stDist = wswb_post_dist_eval(Pdist,false);
	st.PARAMFIT.pymc.(ptype).dist_stats = stDist;
	
	% PLOT
	hf = figure; hold on; box on;
	histnorm(Pdist,100)
	plot(stDist.KDE.x,stDist.KDE.Pd,'r','LineWidth',2)
	scatter(stDist.quant.p50.lower,stDist.quant.p50.prob,'om','filled') 
	scatter(stDist.quant.p25.lower,stDist.quant.p25.prob,'or','filled')
	scatter(stDist.quant.p25.upper,stDist.quant.p25.prob,'or','filled')
	scatter(stDist.quant.p50.upper,stDist.quant.p50.prob,'om','filled')
	title(['Param ',ptype(end),': ',num2str(st.ID),' ',st.METADATA.ws.GAGESII.BASINID.STANAME])
	xlabel('param value')
	ylabel('PDF')
	axis tight
	if max(stDist.KDE.x) < 2, xlim([0,1]), end
	legend('hist','KDE','50 quant','25 quant','location','best')
	set(gca,'FontSize',14,'fontWeight','bold')
	set(findall(hf,'type','text'),'fontSize',14,'fontWeight','bold')
	saveas(hf,fullfile(dir_plot,[fname_plot,ptype]),'fig')
	saveas(hf,fullfile(dir_plot,[fname_plot,ptype]),'png')
	close(hf)
end
warning('on','all')


