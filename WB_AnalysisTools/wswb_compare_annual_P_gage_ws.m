function wswb_compare_annual_P_gage_ws(st_master,id)


%% INITIALIZE
if nargin < 2
	id = 11464500;
end
mindays = 335;
maxP = 5000;

dir_ghcn_data = WB_PARAMS('dir_ghcn_data');

idx = find([st_master(:).ID]==id);
stws = st_master(idx);

%% LUMPED AVERAGE PRECIP
% PRISM
Pprism = stws.P.mo_cy.PRISM.data;
Yprism = stws.P.mo_cy.PRISM.year;
Nchk = sum(~isnan(Pprism),2)==12;
Pprism = sum(Pprism(Nchk,:),2);
Yprism = Yprism(Nchk);

%% NEARBY GHCND STATIONS
GSTA = stws.METADATA.gage_data.ghcn.closest3.sites;
Gdist = stws.METADATA.gage_data.ghcn.closest3.dist;
% GSTA = stws.METADATA.gage_data.ghcn.internal.sites;
% if isempty(GSTA)
% 	display('No data')
% 	return
% end

%% LOAD GHCND DATA
hf = figure; hold on, box on, axis equal
ii = 1;
clr = {'b','m','r','g','c'};
for gg = 1:length(GSTA)
	fname = [GSTA{gg},'.mat'];
	load(fullfile(dir_ghcn_data,fname));
	% stg(gg) = st_ghcnd;
	
	p = double(st_ghcnd.data.prcp.data);
	p(p==-9999) = nan;
	p = p/10;				% **** Units seem to be mm*10? ****
	yrs = double(st_ghcnd.data.prcp.year);

	Nchk = sum(~isnan(p),2) > mindays;
	p = p(Nchk,:);
	yrs = yrs(Nchk);
	ptot = nansum(p,2);
	Pchk = ptot < maxP;		% neglect unrealistically large gage values
	ptot = ptot(Pchk);
	yrs = yrs(Pchk);
	
	% Find years common to PRISM data
	pcommon = wswb_common_years({Pprism,ptot},{Yprism,yrs});
	
	% linear fit of PRISM vs Gage
	[pfit,S] = polyfit(pcommon{2},pcommon{1},1);
	[Pval,Pdelta] = polyval(pfit,pcommon{2},S);
	r2 = rsquare(pcommon{1},Pval,1);
	rmse = sqrt(mean((Pval-pcommon{1}).^2));
	
	% Plot data
	hs = scatter(pcommon{2},pcommon{1},'filled',clr{gg},'Marker','d');
	% Plot fit
	[ymin,imin] = min(Pval); [ymax,imax] = max(Pval);
	xmin = pcommon{2}(imin); xmax = pcommon{2}(imax);
	plot([xmin,xmax],[ymin,ymax],'--','Color',get(hs,'Cdata'))
	
	% ***** STORE LIN FIT VALUES AND R2 TO DISPLAY IN LEGEND *****
	legtxt{ii} = [GSTA{gg},'  (',num2str(round(Gdist(gg))),' km)']; ii=ii+1;
	if pfit(2)<0, txtsign = ''; else txtsign = '+'; end
	legtxt{ii} = [num2str(round(pfit(1)*100)/100),'x ',txtsign,num2str(round(pfit(2))),...
				  '  (R2=',num2str(round(r2*100)/100),',RMSE=',num2str(round(rmse)),')']; ii = ii+1;
	
	PFIT(gg,:) = pfit;
	R2(gg,1) = r2;
	RMSE(gg,1) = rmse;
	xx = 1;
end
xl = xlim; yl = ylim;
xlim([0,xl(2)]); ylim([0,yl(2)]);
title([stws.METADATA.ws.GAGESII.BASINID.STANAME,' ',num2str(id)])
xlabel('Gage P (mm/yr)')
ylabel('PRISM P (mm/yr)')
legend(legtxt,'location','best')

%% SAVE PLOT
dir_master = WB_PARAMS('dir_master');
dir_ws = stws.DIR;
fname = 'PRISM_v_Gage_AnnualP';
fpath = fullfile(dir_master,dir_ws,'DATA_PRODUCTS',fname);
saveas(hf,[fpath,'.fig'])
saveas(hf,[fpath,'.png'])
close(hf)

xx = 1; % debug