% wswb_stationary_check_script

id = 11522500;
idx = find([st_master(:).ID]==id);
st = st_master(idx);

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

% Common Years
[~,iv,ir] = intersect(pvwy,rwy);
Pv = Pv(iv);
Rv = R(ir);
[~,ip,ir] = intersect(ppwy,rwy);
Pp = Pp(ip);
Rp = R(ir);


xx = 1;