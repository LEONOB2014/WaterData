% wswb_export_PR_python_script

wsid = 11451715;

idx = find([st_master(:).ID]==wsid);


st = st_master(idx);
R = st.WYtot.R.USGS.mo_cy.Oct1.data;
P = st.WYtot.P.PRISM.mo_cy.Oct1.data;
Ry = st.WYtot.R.USGS.mo_cy.Oct1.year;
Py = st.WYtot.P.PRISM.mo_cy.Oct1.year;
[DC,DCyrs] = wswb_common_years({R,P},{Ry,Py});

R = DC{1};
P = DC{2};
figure
scatter(P,R,'filled')
title(num2str(wsid))
box on
ylabel('R (mm)')
xlabel('P (mm)')

params = st.MODELS.TriLin.params;
Pa = params(2); 
Pb = params(4); 
B = -params(3);
Rb = B*(Pb-Pa);


PyPath = '/Users/tcmoran/Documents/CODE/Python/WaterData';
[Psort,idx] = sort(P);
Rsort = R(idx);
csvwrite(fullfile(PyPath,'Robs.txt'),round(10*Rsort')/10)
csvwrite(fullfile(PyPath,'Pobs.txt'),round(10*Psort')/10)
