function wswb_export_p_r(st_ws)

%% DIR SETUP
mdir = '/Users/tcmoran/Desktop/Catchment Analysis 2011/AA_CA_Catchments_Master/GAGESII_CATCHMENTS_CA/GAGESII_CATCHMENTS_219';
% mdir = '/Volumes/tcmoran/Desktop/WSWB_ANALYSIS/WS_DATA/GAGESII_CATCHMENTS_219/html';
cdir = st_ws.DIR;
dir_fit = 'PARAM_FIT';
DIR_FIT = fullfile(mdir,cdir,dir_fit);


Ptypes = {'PRISM','VIC','VICs'};
if ~isdir(DIR_FIT)
	mkdir(DIR_FIT);
end
for ii=1:length(Ptypes)
	ptype = Ptypes{ii};
	pdir = fullfile(DIR_FIT,['PDATA_',ptype]);
	if ~isdir(pdir)
		mkdir(pdir)
		mkdir(fullfile(pdir,'1_INTVLS'))
		mkdir(fullfile(pdir,'2_INTVLS'))
		mkdir(fullfile(pdir,'3_INTVLS'))
	end
end
dir_orig = cd(DIR_FIT);
fname_tpr = 'tpr.csv';
fname_pall = 'p_all.csv';

%% ANNUAL WB DATA: PRISM P
% 'WB' field validated for NdaysR and Hydrol Disturb
wb = st_ws.WB.wy.PRISM_USGS.data;
RP	= wb(:,3);
PP	= wb(:,2);
wyWB = st_ws.WB.wy.PRISM_USGS.year;
wy_PP_R = [wyWB,PP,RP];
if isempty(wy_PP_R), wy_PP_R = [0,0,0]; end			% include at least one line for R import, ignore on R side
csvwrite(fullfile(['PDATA_','PRISM'],fname_tpr),wy_PP_R)

% also save file with entire PRISM P record
PPall = st_ws.WYtot.P.PRISM.mo_cy.Oct1.data;
wyPPall = st_ws.WYtot.P.PRISM.mo_cy.Oct1.year;
csvwrite(fullfile(['PDATA_','PRISM'],fname_pall),[wyPPall, PPall])

%% VIC P
PV = st_ws.WYtot.P.VIC.mo_cy.Oct1.data;
PV = round(PV);																		% nearest mm
wyV = st_ws.WYtot.P.VIC.mo_cy.Oct1.year;

%% VIC SCALED P
% VIC data scaled by linear fit to PRISM
PVs = st_ws.WYtot.P.VIC_Scaled.mo_cy.Oct1.data;
PVs = round(PVs);																	% nearest mm
wyVs = st_ws.WYtot.P.VIC_Scaled.mo_cy.Oct1.year;
% scaled years should always be identical to non-scaled VIC years, but check
if max(abs(wyV-wyVs))>0
	display(['Uh, oh, problem with VIC data years for watershed  ',st_ws.ID])
end

% get valid years for VIC data
[ixWB,idxV] = ismember(wyWB,wyV);
idxV = idxV(idxV>0);
PVwb = PV(idxV);
PVswb = PVs(idxV);
wyVwb = wyV(idxV);
[~,idxR] = ismember(wyVwb,wyWB);
RV = RP(idxR);															% runoff for valid VIC years


wy_PV_R = [wyVwb,PVwb,RV];
if isempty(wy_PV_R), wy_PV_R = [0,0,0];	end			% include at least one line for R import, ignore on R side
csvwrite(fullfile(['PDATA_','VIC'],fname_tpr),wy_PV_R)
% ... and all VIC P data
csvwrite(fullfile(['PDATA_','VIC'],fname_pall),[wyV,PV])


% VIC SCALED P
wy_PVs_R = [wyVwb,PVswb,RV];
if isempty(wy_PVs_R), wy_PVs_R = [0,0,0];	end			% include at least one line for R import, ignore on R side
csvwrite(fullfile(['PDATA_','VICs'],fname_tpr),wy_PVs_R)
% ... and all VIC P data
csvwrite(fullfile(['PDATA_','VICs'],fname_pall),[wyV,PVs])

% % also copy to networked directories  ***** TEMPORARY AD HOC *****
% mdirS = '/Volumes/tcmoran/Desktop/WSWB_ANALYSIS/WS_DATA/GAGESII_CATCHMENTS_219';
% path_fitS = fullfile(mdirS,cdir,dir_fit, fnameVs);
% csvwrite(path_fitS,wy_PVs_R)


% PLOT VIC VS PRISM FOR WATER BALANCE INTERVAL (R DATA COVERAGE)
figname = fullfile(['PDATA_','VIC'], 'VIC_vs_PRISM_WB');
pv = PVwb;
pp = PP(ixWB);
plot_p_compare(pv,pp,wyVwb,figname)


%% P ONLY, PRISM & VIC
PP_mo	= st_ws.P.mo_cy.PRISM.data;
cyPP	= st_ws.P.mo_cy.PRISM.year;
[PP_mo,wyP]= cy2wy_monthly(PP_mo,cyPP,10);			% convert to wy
PPall = sum(PP_mo,2);									% yearly total

% common years
[~,idxP] = ismember(wyV,wyP);
idxP = idxP(idxP>0);
wy_PP_PV = [wyV,PPall(idxP),PV];
csvwrite(fullfile(['PDATA_','VIC'],'pp_pv.csv'),wy_PP_PV)

% PLOT VIC VS PRISM, ALL COMMON YEARS
figname = fullfile(['PDATA_','VIC'], 'VIC_vs_PRISM_ALL');
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
