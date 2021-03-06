function st = wswb_P_VIC_scaledby_PRISM(st)

% WSWB_PRECIP_VIC_VS_PRISM(st) estimates the linear relationship of VIC ~
% PRISM for the specified interval and returns a new or modified structure
% for the given watershed
%
% INPUTS
% st	= wswb structure for a given watershed
%
% OUTPUTS
% st	= modified wswb structure
%
% TC Moran, 2014

WYintvl = 1961:1990;		% VIC is scaled by PRISM over this interval (per methodology refs)

%% VIC precip
PVcy = st.P.mo_cy.VIC.data;
cyPV = st.P.mo_cy.VIC.year;
[PVwy,wyPV] = cy2wy_monthly(PVcy,cyPV,10);
PVwy = sum(PVwy,2);
PVwyInt = PVwy(ismember(wyPV,WYintvl));

%% PRISM precip
PPcy = st.P.mo_cy.PRISM.data;
cyPP = st.P.mo_cy.PRISM.year;
[PPwy,wyPP] = cy2wy_monthly(PPcy,cyPP,10);
PPwy = sum(PPwy,2);
PPwyInt = PPwy(ismember(wyPP,WYintvl));

%% LIN REGRESS: PP ~ PV
pfit = polyfit(PVwyInt,PPwyInt,1);
st.P.mo_cy.VIC.LinFitParams_PRISM_vs_VIC = pfit;

%% APPLY REGRESSION TO SCALE VIC
PvicScaled = polyval(pfit,PVwy);		% PVscaled(PV) = (PV~PP)^-1

st.WYtot.P.VIC_Scaled.mo_cy.Oct1.data = PvicScaled;
st.WYtot.P.VIC_Scaled.mo_cy.Oct1.year = wyPV;
st.WYtot.P.VIC_Scaled.mo_cy.Oct1.note = 'VIC P scaled by lin fit with yearly PRISM P, 1961-1990';

% %% PLOT (OPTIONAL)
% hf=figure;
cla
plot(PVwyInt, PPwyInt, 'o'); hold on
% plot(PVwyInt, polyval(pfit,PVwyInt),'.k')
plot(PVwy, PvicScaled, '.k')
xlabel('VIC (mm)'); ylabel('PRISM (mm)')
title(['PP = ',num2str(pfit(2),3),' + ',num2str(pfit(1),3),'*PV'])
pause(0.5)
% close(hf);
xx=1; % debug 