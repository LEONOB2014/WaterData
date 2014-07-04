function wswb_export_pGage_r(st_ws)


%% DIR SETUP
mdir = '/Users/tcmoran/Desktop/Catchment Analysis 2011/AA_CA_Catchments_Master/GAGESII_CATCHMENTS_CA/GAGESII_CATCHMENTS_219';
cdir = st_ws.DIR;
dir_fit = 'PARAM_FIT';
DIR_FIT = fullfile(mdir,cdir,dir_fit);
dir_ghcn = 'GAGE_PRECIP_TEMP_GHCN';
DIR_GHCN = fullfile(mdir,cdir,dir_ghcn);
fname_ghcn = 'GHCN_PT_closest3_allyears.mat';

Ptypes = {'GHCN'};
for ii=1:length(Ptypes)
	ptype = Ptypes{ii};
	pdir = fullfile(DIR_FIT,['PDATA_',ptype]);
	if ~isdir(pdir)
		mkdir(pdir);
		mkdir(fullfile(pdir,'1_INTVLS'));
		mkdir(fullfile(pdir,'2_INTVLS'));
		mkdir(fullfile(pdir,'3_INTVLS'));
	end
end
dir_orig = cd(DIR_FIT);
fname_tpr = 'tpr.csv';
fname_pall = 'p_all.csv';

%% ANNUAL WB DATA: RUNOFF
% 'WB' field validated for NdaysR and Hydrol Disturb
wb = st_ws.WB.wy.PRISM_USGS.data;
R	= wb(:,3);
wyR = st_ws.WB.wy.PRISM_USGS.year;

%% IMPORT GHCN GAGE DATA
load(fullfile(DIR_GHCN,fname_ghcn))
PG = st_pt_ghcnd.best.p.wy_tot;
PG = round(PG);
wyG = st_pt_ghcnd.best.p.wy;

% get years common to R data
[ixR,idxG] = ismember(wyR,wyG);
idxG = idxG(idxG>0);
PGr = PG(idxG);
wyGr = wyG(idxG);
[~,idxR] = ismember(wyGr,wyR);
RG = R(idxR);

wy_PG_R = [wyGr,PGr,RG];
if isempty(wy_PG_R), wy_PG_R = [0,0,0];	end			% include at least one line for R import, ignore on R side
csvwrite(fullfile(['PDATA_','GHCN'],fname_tpr),wy_PG_R)

% also save file with entire PRISM P record
csvwrite(fullfile(['PDATA_','GHCN'],fname_pall),[wyG, PG])

%% VIC P
PV_mo	= st_ws.P.mo_cy.VIC.data;
cyPv	= st_ws.P.mo_cy.VIC.year;
[PV_mo,wyV]= cy2wy_monthly(PV_mo,cyPv,10);			% convert to wy
PV = sum(PV_mo,2);															% yearly total

% get valid years for VIC data
[ixR,idxV] = ismember(wyR,wyV);
idxV = idxV(idxV>0);
PVwb = PV(idxV);
wyVwb = wyV(idxV);

% % PLOT VIC VS GHCN FOR WATER BALANCE INTERVAL (R DATA COVERAGE)
% figname = 'VIC_vs_GHCN_WB';
% pv = PVwb;
% pg = PG(ixR);
% plot_p_compare(pv,pg,wyVwb,figname)

%% GHCN & VIC P PLOTS
% common years
[ixV,idxG] = ismember(wyV,wyG);
idxG = idxG(idxG>0);
wy_PG_PV = [wyV(ixV),PG(idxG),PV(ixV)];
csvwrite(fullfile('PDATA_GHCN','pg_pv.csv') ,wy_PG_PV)

% PLOT VIC VS PRISM, ALL COMMON YEARS
figname = fullfile('PDATA_GHCN', 'VIC_vs_GHCN_ALL');
pv = PV(ixV);
pg = PG(idxG);
plot_p_compare(pv,pg,wyV(ixV),figname)

cd(dir_orig)

%% PLOT VIC VS PRISM
function plot_p_compare(p1,p2,t,figname)

fsz = 12;
hf = figure('position',[110 190 950 400]);
subplot(121)
plot(p1,p2,'bo')
xlabel('VIC (mm)')
ylabel('GHCN (mm)')
xl = xlim; yl = ylim;
amax = max([xl,yl]);
line([0,amax],[0,amax],'color','k','linestyle',':')
% linear fit
pfit_p1p2 = polyfit(p1,p2,1);
x1 = [min(p1),max(p1)];
line(x1,polyval(pfit_p1p2,x1),'color','b')
title(['Precip: ',num2str(min(t)),'-',num2str(max(t)),', y = ',num2str(pfit_p1p2(1),3),'*x + ',num2str(round(pfit_p1p2(2))),'  '])
% set(gca,'FontSize',fsz,'fontWeight','bold')

%% PLOT RESIDUALS
dP = p2-polyval(pfit_p1p2,p1);
subplot(122)
plot(t,dP,'bo')
pfit_dP = polyfit(t,dP,1);
x2 = [min(t),max(t)];
line(x2,polyval(pfit_dP,x2),'color','b')
title(['p2 vs p1 f(time), Slope = ',num2str(pfit_dP(1),3),'  '])
ylabel('P regression residual (mm)')
xlabel('WY')
axis tight

% set(gca,'FontSize',fsz,'fontWeight','bold')
% set(findall(gcf,'type','text'),'FontSize',fsz,'fontWeight','bold')

set(hf,'PaperUnits','inches','PaperSize',[6,3],'PaperPosition',[0 0 6 3])
saveas(hf,figname,'fig')
% saveas(hf,figname,'png')
print(hf, '-dpng','-r200', [figname,'.png'])
close(hf)
