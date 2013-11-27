function dir_site = match_site_id_dir(id)

mdir = WB_PARAMS('dir_master');
site_list = WB_PARAMS('wslist_ca219');
site_dirs = import_catchment_list(fullfile(mdir,site_list),mdir);
Ns = length(site_dirs);

if isnumeric(id)
	id = num2str(id);
end

dir_site = [];
for ii = 1:Ns
	if ~isempty(strfind(site_dirs{ii},id))
		dir_site = site_dirs{ii};
		break
	end
end

xx = 1;