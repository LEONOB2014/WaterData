function st_pt_ghcnd = wswb_export_nearby_ghcn_PT(st_master,idx)


%% INITIALIZE
if nargin < 2
	idx = 1;
end
mindays = 335;
maxP = 5000;

dir_ghcn_data	  = WB_PARAMS('dir_ghcn_data');
dir_master			= WB_PARAMS('dir_master');
dir_ghcn_save     = WB_PARAMS('dir_ghcn_save');
fname_save			= 'GHCN_PT_closest3_allyears.mat';

stws = st_master(idx);
dir_ws = stws.DIR;

%% PRISM
Pprism = stws.P.mo_cy.PRISM.data;
Yprism = stws.P.mo_cy.PRISM.year;
Nchk = sum(~isnan(Pprism),2)==12;
Pprism = sum(Pprism(Nchk,:),2);
Pprism_mean = mean(Pprism);
Pprism_sd = std(Pprism);
Yprism = Yprism(Nchk);


%% GHCND SITE WITH BEST LINFIT TO PRISM
GSTA{1} = stws.METADATA.gage_data.ghcn.BestLinFit.ghcn_site.id;
Gdist(1)  = stws.METADATA.gage_data.ghcn.BestLinFit.ghcn_site.dist_from_boundary_km;

%% NEARBY GHCND STATIONS
gsta = stws.METADATA.gage_data.ghcn.closest3.sites;
for ii=2:4, GSTA{ii} = gsta{ii-1}; end
Gdist(2:4) = stws.METADATA.gage_data.ghcn.closest3.dist;


%% LOAD GHCND DATA
hf1 = figure; hold on; box on
set(gca,'ytick',[1:4],'ytickLabel',GSTA)
ylim([0.5, 4.5])
title('Valid Data Years')
xlabel('Water Year')
ha1 = gca;

% hf2 = figure; hold on; box on
% ha2 = gca;
% plot(ha2,Yprism,Pprism,'color','k','linewidth',2)

clrs = {'b','r','m','g'};
for gg = 1:length(GSTA)
	fname = [GSTA{gg},'.mat'];
	try
		load(fullfile(dir_ghcn_data,fname));
		p = double(st_ghcnd.data.prcp.data_filt);
		yrs = double(st_ghcnd.data.prcp.year_filt);
	catch
		continue
	end
	
	p(p==-9999) = nan;
	p = p/10;				% **** Precip units are mm*10 ****
	
	
	% convert from cy to wy
	[p, yrs] = cy2wy_daily(p,yrs);
	
	Nchk = sum(~isnan(p),2) > mindays;
	p = p(Nchk,:);
	yrs = yrs(Nchk);
	ptot = nansum(p,2);
	Pchk = ptot < maxP;		% neglect unrealistically large gage values
	ptot = ptot(Pchk);
	yrs = yrs(Pchk);
	p   = p(Pchk,:);
	
	st_pt_ghcnd.ghcn_id(gg).name = GSTA{gg};
	st_pt_ghcnd.ghcn_id(gg).dist2ws_centroid_km = Gdist(gg);
	st_pt_ghcnd.ghcn_id(gg).p.wy		 = yrs;
	st_pt_ghcnd.ghcn_id(gg).p.daily		 = p;
	st_pt_ghcnd.ghcn_id(gg).p.wy_tot  = ptot;
	
	P{gg} = p;
	Ptot{gg} = ptot;
	Ptot_mean(gg) = mean(ptot);
	Ptot_sd(gg) = std(ptot);
	YRS{gg} = yrs;
	
	plot(ha1,yrs, gg, 'ok')
	% 	plot(ha2,yrs,ptot,clrs{gg})
	
end


%% CHOOSE BEST SOURCE OF GHCN GAGE DATA
%  The main use for gage data is to examine RvP for years after VIC data
%  ends, 2003+
for ii = 1:length(YRS)
	yrsValid(ii,1) = sum(YRS{ii} > 2003);
	yrsTot(ii,1)   = length(YRS{ii});
end
yrchk = yrsValid > 7 & yrsTot > 30;

if max(yrchk) > 0									%  FIRST USE LOC WITH CLOSEST MATCH TO MEAN PRISM P THAT MEETS YEAR CRITERIA
	[~,ix] = min(abs(Pprism_mean - Ptot_mean(yrchk)));
	IX = find(yrchk > 0);
	ix_best = IX(ix);
else
	if max(yrsValid) > 1							% if any locs have any years after 2003, use loc with most
		[~,ix_best] = max(yrsValid);
	else
		[~,ix_best] = max(yrsTot);				%  default  to loc with longest record
	end
end


st_pt_ghcnd.best.ghcn_id = GSTA{ix_best};
st_pt_ghcnd.best.dist2ws_centroid_km = Gdist(ix_best);
st_pt_ghcnd.best.p.wy		 = YRS{ix_best};
st_pt_ghcnd.best.p.daily		 = P{ix_best};
st_pt_ghcnd.best.p.wy_tot  = Ptot{ix_best};


%% SAVE FILE & FIGURE
DIR_save = fullfile(dir_master,dir_ws,dir_ghcn_save);
save(fullfile(DIR_save,fname_save),'st_pt_ghcnd')
saveas(hf1, fullfile(DIR_save,'GHCN_PT_closest3_data_coverage'),'fig')
saveas(hf1, fullfile(DIR_save,'GHCN_PT_closest3_data_coverage'),'png')
close(hf1)