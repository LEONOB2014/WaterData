% wswb_html_script

mdir = '/Users/tcmoran/Desktop/Catchment Analysis 2011/AA_CA_Catchments_Master/GAGESII_CATCHMENTS_CA/GAGESII_CATCHMENTS_219';
cd(mdir)
ws_file = './HUC18010110/CATCHMENT_Parent18010110_Site11461000_RUSSIAN_R_NR_UKIAH_CA/watershed_overview.html';
pdir = './HUC18010110/CATCHMENT_Parent18010110_Site11461000_RUSSIAN_R_NR_UKIAH_CA/PARAM_FIT';
p1_file = fullfile(pdir,'param_fit1.html');
p2_file = [pdir,'/param_fit2.html'];
p3_file = [pdir,'/param_fit3.html'];


for ii = 53:219
	cdir = st_master(ii).DIR;
% 	copyfile(ws_file,cdir)
	copyfile(p1_file,fullfile(cdir,'PARAM_FIT'))
% 	copyfile(p2_file,fullfile(cdir,'PARAM_FIT'))
% 	copyfile(p3_file,fullfile(cdir,'PARAM_FIT'))
end