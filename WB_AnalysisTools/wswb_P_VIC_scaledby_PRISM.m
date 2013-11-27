function st = wswb_P_VIC_scaledby_PRISM(st)

Pvic = st.P.mo_cy.VIC.data;
Pcys = st.P.mo_cy.VIC.year;
[Pvic,Pwys] = cy2wy_monthly(Pvic,Pcys,10);
PvicTot = sum(Pvic,2);

pfit = st.P.mo_cy.VIC.WYtot_LinFit_vs_PRISM;

PvicScaled = (PvicTot-pfit(2))./pfit(1);
st.P.wytot.Oct1.VIC_scaledby_PRISM.data = PvicScaled;
st.P.wytot.Oct1.VIC_scaledby_PRISM.year = Pwys;

xx = 1;