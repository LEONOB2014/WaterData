function wswb_export_p_r(st_master,wsidx,tidx1)


%% INITIALIZE
if nargin < 3, tidx1 = 1; end		% default to first time index

%% DIR SETUP
mdir = '/Users/tcmoran/Desktop/Catchment Analysis 2011/AA_CA_Catchments_Master/GAGESII_CATCHMENTS_CA/GAGESII_CATCHMENTS_219';
cdir = st_master(wsidx).DIR;
dir_fit = 'PARAM_FIT';
DIR_FIT = fullfile(mdir,cdir,dir_fit);

Ptypes = {'PRISM','VIC'};
if ~isdir(DIR_FIT)
	mkdir(DIR_FIT);
	for ii=1:length(Ptypes)
		ptype = Ptypes{ii};
		pdir = fullfile(DIR_FIT,['PDATA_',ptype]);
		mkdir(pdir);
		mkdir(fullfile(pdir,'1_INTVLS'));
		mkdir(fullfile(pdir,'2_INTVLS'));
		mkdir(fullfile(pdir,'3_INTVLS'));
	end
end
dir_orig = cd(DIR_FIT);


fnameP	= 'PRISM_tpr.csv';
fnameV	= 'VIC_tpr.csv';
fnamePV = 'PRISM_VIC_p.csv';
Nmin	= 30;	% min # years of data

%% ANNUAL WB DATA: PRISM P
% 'WB' field validated for NdaysR and Hydrol Disturb
wb = st_master(wsidx).WB.wy.PRISM_USGS.data; 
wb = wb(tidx1:end,:);
RP	= wb(:,3); 
PP	= wb(:,2); 
wyWB = st_master(wsidx).WB.wy.PRISM_USGS.year; 
wyWB = wyWB(tidx1:end);
wy_PP_R = [wyWB,PP,RP];
if isempty(wy_PP_R), wy_PP_R = [0,0,0]; end			% include at least one line for R import, ignore on R side
csvwrite(fnameP,wy_PP_R)

%% VIC P
PV_mo	= st_master(wsidx).P.mo_cy.VIC.data;
cyPv	= st_master(wsidx).P.mo_cy.VIC.year;
[PV_mo,wyV]= cy2wy_monthly(PV_mo,cyPv,10);			% convert to wy
PV = sum(PV_mo,2);									% yearly total

% get valid years for VIC data
[ixWB,idxV] = ismember(wyWB,wyV);
idxV = idxV(idxV>0);
PVwb = PV(idxV);
wyVwb = wyV(idxV);
[~,idxR] = ismember(wyVwb,wyWB);
RV = RP(idxR);

wy_PV_R = [wyVwb,PVwb,RV];
if isempty(wy_PV_R), wy_PV_R = [0,0,0];	end			% include at least one line for R import, ignore on R side 
csvwrite(fnameV,wy_PV_R)

% PLOT VIC VS PRISM FOR WATER BALANCE INTERVAL (R DATA COVERAGE)
figname = 'VIC_vs_PRISM_WB';
pv = PVwb;
pp = PP(ixWB);
plot_p_compare(pv,pp,wyVwb,figname)


%% P ONLY, PRISM & VIC
PP_mo	= st_master(wsidx).P.mo_cy.PRISM.data;
cyPP	= st_master(wsidx).P.mo_cy.PRISM.year;
[PP_mo,wyP]= cy2wy_monthly(PP_mo,cyPP,10);			% convert to wy
PPall = sum(PP_mo,2);									% yearly total

% common years
[~,idxP] = ismember(wyV,wyP);
idxP = idxP(idxP>0);
wy_PP_PV = [wyV,PPall(idxP),PV];
csvwrite(fnamePV,wy_PP_PV)

% PLOT VIC VS PRISM, ALL COMMON YEARS
figname = 'VIC_vs_PRISM_ALL';
pv = PV;
pp = PPall(idxP);
plot_p_compare(pv,pp,wyV,figname)

cd(dir_orig)

%% PLOT VIC VS PRISM
function plot_p_compare(p1,p2,t,figname)

fsz = 12;
hf = figure('position',[110 190 950 400]);
subplot(121)
plot(p1,p2,'bo')
xlabel('VIC (mm)')
ylabel('PRISM (mm)')
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
