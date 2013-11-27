% wswb_stationary_check_script

id = 11522500;
idx = find([st_master(:).ID]==id);
st = st_master(idx);
Pfit = st.P.mo_cy.VIC.WYtot_LinFit_vs_PRISM;

% R data
r = st.R.mo_cy.USGS.data;
ry = st.R.mo_cy.USGS.year;
[r,rwy] = cy2wy_monthly(r,ry,10);
R = sum(r,2);

% P PRISM
pp = st.P.mo_cy.PRISM.data;
ppy = st.P.mo_cy.PRISM.year;
[pp,ppwy] = cy2wy_monthly(pp,ppy,10);
Pp = sum(pp,2);

% P VIC
pv = st.P.mo_cy.VIC.data;
pvy = st.P.mo_cy.VIC.year;
[pv,pvwy] = cy2wy_monthly(pv,pvy,10);
Pv = sum(pv,2);
% adjust by VIC vs PRISM linfit
Pv = (Pv-Pfit(2))./Pfit(1);

% Common Years
[~,iv,ir] = intersect(pvwy,rwy);
Pvr = Pv(iv);						% Pv for R
Rv = R(ir);							% R for Pv
wy_vr = rwy(ir);
[~,ip,ir] = intersect(ppwy,rwy);
Ppr = Pp(ip);						% Pp for R
Rp = R(ir);							% R for Pp
wy_pr = rwy(ir);
[~,ip,iv] = intersect(ppwy,pvwy);
Ppv = Pp(ip);						% Pp for Pv
Pvp = Pv(iv);						% Pv for Pp
wy_pv = pvwy(iv);

% Zero-phase moving average filter
% PvR = Pvr-Rv;
% PvR = PvR(~isnan(PvR));
% Pvr = Pvr(~isnan(PvR));
% Rv = Rv(~isnan(PvR));
% wsz = 25;
% PvRfilt = filtfilt(ones(1,wsz)/wsz,1,PvR);

xx = 1;