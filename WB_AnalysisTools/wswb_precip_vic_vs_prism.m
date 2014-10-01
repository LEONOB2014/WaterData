function st = wswb_precip_vic_vs_prism(st)

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

%% LIN REGRESS: PV ~ PP
pfit = polyfit(PPwyInt,PVwyInt,1);
st.P.mo_cy.VIC.WYtot_LinFit_vs_PRISM = pfit;

%% APPLY REGRESSION TO SCALE VIC
PvicScaled = (PVwy-pfit(2))./pfit(1);		% PVscaled(PV) = (PV~PP)^-1
st.P.wytot.Oct1.VIC_scaledby_PRISM.data = PvicScaled;
st.P.wytot.Oct1.VIC_scaledby_PRISM.year = wyPV;

% %% PLOT (OPTIONAL)
% plot(PPwyInt, PVwyInt,'o'); hold on
% plot(PPwyInt, polyval(pfit,PPwyInt),'.k')
xx=1; % debug 