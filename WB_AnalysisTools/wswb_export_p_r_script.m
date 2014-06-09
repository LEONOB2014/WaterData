% WSWB_EXPORT_P_R_SCRIPT

ww		= ii;	% watershed index
fnameP	= 'PRISM_tpr.csv';
fnameV	= 'VIC_tpr.csv';
Nmin	= 30;	% min # years of data

% WB field validated for NdaysR and Hydrol Disturb
wb = st_master(ww).WB.wy.PRISM_USGS.data; 
if size(wb,1) < Nmin
	display('not enough data')
	return
end
RP	= wb(:,3); 
PP	= wb(:,2); 
wyWB = st_master(ii).WB.wy.PRISM_USGS.year; 
wy_PP_R = [wyWB,PP,RP];
csvwrite(fnameP,wy_PP_R)

PV_mo	= st_master(ww).P.mo_cy.VIC.data;
cyPv	= st_master(ww).P.mo_cy.VIC.year;
[PV_mo,wyV]= cy2wy_monthly(PV_mo,cyPv,10);			% convert to wy
PV = sum(PV_mo,2);									% yearly total

% get valid years for VIC data
[ixWB,idxV] = ismember(wyWB,wyV);
idxV = idxV(idxV>0);
PV = PV(idxV);
wyV = wyV(idxV);
[~,idxR] = ismember(wyV,wyWB);
RV = RP(idxR);

wy_PV_R = [wyV,PV,RV];
csvwrite(fnameV,wy_PV_R)

%% PLOT VIC VS PRISM
fsz = 16;
hf = figure('position',[110 190 950 400]);
subplot(121)
plot(PV,PP(ixWB),'ko')
xlabel('VIC (mm)')
ylabel('PRISM (mm)')
xl = xlim; yl = ylim;
amax = max([xl,yl]);
line([0,amax],[0,amax],'color','k','linestyle',':')
% linear fit
pfit_PV = polyfit(PV,PP(ixWB),1);
x1 = [min(PV),max(PV)];
line(x1,polyval(pfit1,x1),'color','b')
title(['Precip: ',num2str(min(wyV)),'-',num2str(max(wyV)),', y = ',num2str(pfit_PV(1),3),'*x + ',num2str(round(pfit_PV(2)))])
set(gca,'FontSize',fsz,'fontWeight','bold')

%% PLOT RESIDUALS
dP = PP(ixWB)-polyval(pfit1,PV);
subplot(122)
plot(wyV,dP,'ko')
pfit_dP = polyfit(wyV,dP,1);
x2 = [min(wyV),max(wyV)];
line(x2,polyval(pfit_dP,x2),'color','b')
title(['Pp vs Pv f(time), Slope = ',num2str(pfit_dP(1))])
ylabel('P regression residual (mm)')
xlabel('WY')
axis tight

set(gca,'FontSize',fsz,'fontWeight','bold')
set(findall(gcf,'type','text'),'FontSize',fsz,'fontWeight','bold')