% wswb_export_PR_python_script

% wsid = 11274630;
% 
% idx = find([st_master(:).ID]==wsid);

for idx = 1:219
	
	st = st_master(idx);
	R = st.WYtot.R.USGS.mo_cy.Oct1.data;
	P = st.WYtot.P.PRISM.mo_cy.Oct1.data;
	Ry = st.WYtot.R.USGS.mo_cy.Oct1.year;
	Py = st.WYtot.P.PRISM.mo_cy.Oct1.year;
	[DC,DCyrs] = wswb_common_years({R,P},{Ry,Py});
	
	R = DC{1};
	P = DC{2};
	% sanity check R < P
	Rchk = R<P;
	P = P(Rchk);
	R = R(Rchk);
	
% 	% Plot
% 	figure
% 	scatter(P,R,'filled')
% 	title(num2str(wsid))
% 	box on
% 	ylabel('R (mm)')
% 	xlabel('P (mm)')
	
	params = st.MODELS.TriLin.params;
	Pa = params(2);
	Pb = params(4);
	B = -params(3);
	Rb = B*(Pb-Pa);
	
	% Save File
% 	fpath = '/Users/tcmoran/Documents/CODE/Python/WaterData';
	fpath = fullfile(WB_PARAMS('dir_master'),st.DIR,'DATA_PRODUCTS','PR_PARAM_FIT');
	if ~isdir(fpath), mkdir(fpath), end
% 	[Psort,Pidx] = sort(P);
% 	Rsort = R(Pidx);
	csvwrite(fullfile(fpath,'Robs.txt'),round(10*R')/10)
	csvwrite(fullfile(fpath,'Pobs.txt'),round(10*P')/10)
	csvwrite(fullfile(fpath,'WYobs.txt'),DCyrs{1}')
	
end