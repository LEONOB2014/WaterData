% MOPEX Compare Script

% ids for filtered CA219 GAGESII sites:
% [11025500,11080500,11138500,11281000,11224500,...
%  11213500,10296500,10296000,11413000,11342000]

id = 11025500;
idx = find([st_master(:).ID]==id);
mopex = import_mopex(id);


%% MOPEX
[P,R,PET,Tmax,Tmin,Cys] = wswb_process_mopex(mopex);
[Pwym,Ym] = cy2wy_daily(P,Cys,274);
Pm = nansum(Pwym,2);

%% PRISM AND VIC
st = st_master(idx);
Pp = st.WYtot.P.PRISM.mo_cy.Oct1.data;
Yp = st.WYtot.P.PRISM.mo_cy.Oct1.year;
Pv = st.WYtot.P.VIC.mo_cy.Oct1.data;
Yv = st.WYtot.P.VIC.mo_cy.Oct1.year;
P = {Pm,Pp,Pv};
Yr = {Ym,Yp,Yv};
[Pc,Pcyrs] = wswb_common_years(P,Yr);

%% PLOT
figure, hold on
scatter(Pc{1},Pc{2},'b','filled')
scatter(Pc{1},Pc{3},'r','filled')
title([num2str(st.ID),': ',st.METADATA.ws.GAGESII.BASINID.STANAME])
yl = ylim; xl = xlim;
xymax = max(xl(2),yl(2));
line([0,xymax],[0,xymax],'color','k','linestyle','--')
legend('PRISM','VIC','1:1','location','southeast')
xlabel('MOPEX P (mm)')
ylabel('PRISM and VIC P (mm)')
box on