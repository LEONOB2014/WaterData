function [PD,DD] = wswb_fit_mcmc_post_distrib(dir_list)

% WSWB_FIT_MCMC_POST_DISTRIB(dir_list) fits the specified distributions to
% the MCMC posterior data contained within each directory in dir_list.
% 
% Uses output of Pymc MCMC runs from mcmc_run_fit_list.py, analysis split
% between Python and MATLAB because Python distribution fitting in scipy
% does not seem to be very robust.
% 
% INPUTS
% dir_list = name of file containing list of relative paths to watershed
%			 directories to be processed, file must be in dir_master
%
% OUTPUTS
% PD	= structure with posterior distribution best fit and params for
%         each ws
% DD	= Array of posterior distribution values for each site and param
%
% TC Moran UC Berkeley 2013


%% INITIALIZE
if nargin < 1
	dir_list = 'FILTERED_CATCHMENTS_219.txt';
end
fnames = {'post_a.csv','post_b.csv','post_S.csv'};
FitTypes = {'Normal','GeneralizedExtremeValue','ExtremeValue','Logistic'};

mdir = WB_PARAMS('dir_master');
path_list = fullfile(mdir,dir_list);

Clist = import_catchment_list(path_list);

%% IMPORT POST DISTRIBS AND FIND BEST FIT
for cc = 1:length(Clist)
	cdir = Clist{cc};
	ddir = fullfile(mdir,cdir,'DATA_PRODUCTS/PR_PARAM_FIT');
	for dd = 1:length(fnames)
		fname = fnames{dd};
		D = dlmread(fullfile(ddir,fname));
		for ff = 1:length(FitTypes)
			pd(ff) = fitdist(D',FitTypes{ff});
			negloglik(ff) = pd(ff).negloglik;
		end
		[~,idx] = min(negloglik);
		% Default to Normal distrib if other best fit is within 0.2%
		if idx ~= 1 && abs((negloglik(1)-negloglik(idx))/negloglik(idx))<0.002
			idx = 1;
		end
		PD(cc).(fname(1:end-4)) = pd(idx);
		% PLOT
		hf = figure('visible','off'); box on; hold on;
		histnorm(D,50)
		xl = xlim;
		if xl < 2, xl(1)=0; xl(2)=1; end % make all slope plots x values 0 to 1
		dx = (xl(2)-xl(1))/100;
		x = xl(1):dx:xl(2);
		plot(x,pdf(pd(idx),x),'r','Linewidth',2)
		xlabel('Value')
		ylabel('Normalized Count')
		title([pd(idx).DistributionName,': LogLike = ',num2str(-pd(idx).negloglik)])
		saveas(hf, fullfile(ddir,[fname(1:end-4),'.png']))
		close(hf)
		DD(:,cc,dd) = D';
	end
	display([num2str(100*cc/length(Clist)),' % done'])
end

