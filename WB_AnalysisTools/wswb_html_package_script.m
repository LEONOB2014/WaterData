% wswb_html_package_script
% creates a standalone set of water data html files for uploading to the web

%% 
dir_html = '/Users/tcmoran/Desktop/Catchment Analysis 2011/AA_CA_Catchments_Master/GAGESII_CATCHMENTS_CA/GAGESII_CATCHMENTS_219/html';
dir_master = '/Users/tcmoran/Desktop/Catchment Analysis 2011/AA_CA_Catchments_Master/GAGESII_CATCHMENTS_CA/GAGESII_CATCHMENTS_219';
p_master = fullfile(dir_master,'CA_WATERSHEDS_219_OVERVIEW.html');
copyfile(p_master,dir_html)
cd(dir_master)
p_ws = fullfile(dir_master,'watershed_overview.html');	% html file same for all watersheds, only content changes
p_param1 = fullfile(dir_master,'param_fit1.html');
p_param2 =  fullfile(dir_master,'param_fit2.html');
p_param3 =  fullfile(dir_master,'param_fit3.html');

%% LOOP THROUGH WATERSHEDS
Ptypes = {'GHCN','PRISM','VIC'};
for ii = 1:219
	cdir = st_master(ii).DIR;
	chtml = fullfile('html',cdir);
% 	if ~isdir(chtml)			% initialize directory structure
% 		mkdir(chtml)
% 		mkdir(fullfile(chtml, 'PARAM_FIT'))
% 		mkdir(fullfile(chtml, 'DATA_PRODUCTS'))
% 		mkdir(fullfile(chtml, 'boundary'))
% 		for pp = 1:length(Ptypes)
% 			mkdir(fullfile(chtml, 'PARAM_FIT', ['PDATA_',Ptypes{pp}]))
% 			for nn = 1:3
% 				mkdir(fullfile(chtml, 'PARAM_FIT', ['PDATA_', Ptypes{pp}],[num2str(nn),'_INTVLS']))
% 			end
% 		end
% 	end
% 	copyfile(p_ws,chtml)																	% watershed overview page
% 	copyfile(fullfile(cdir,'site_info.csv'),chtml)									% site info file
% 	copyfile(fullfile(cdir,'DATA_PRODUCTS','Catchment_ETest_P_R_v_WY.png'),fullfile(chtml,'DATA_PRODUCTS'))		% P, R vs T overview image
% 	
	copyfile(p_param1,fullfile(chtml,'PARAM_FIT'))						% param fit pages
% 	copyfile(p_param2,fullfile(chtml,'PARAM_FIT'))
% 	copyfile(p_param3,fullfile(chtml,'PARAM_FIT'))
% 	
% 	copyfile(fullfile(cdir,'boundary','boundary_line.kml'),fullfile(chtml,'boundary'))	% watershed boundary kml
	
% 	for pp = 1:length(Ptypes)
% 		pdir = ['PDATA_',Ptypes{pp}];
% 		for nn = 1:3
% 			ndir = [num2str(nn),'_INTVLS'];
% 			try
% 				copyfile(fullfile(cdir,'PARAM_FIT',pdir,ndir,'*.png'),fullfile(chtml,'PARAM_FIT',pdir,ndir))
% 			catch
% 				x = 1;
% 			end
% 			
% 		end
% 	end
	if mod(ii,10)==0, display([num2str(100*ii/219),'% done']), end
end