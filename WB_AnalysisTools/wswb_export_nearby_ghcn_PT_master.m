function wswb_export_nearby_ghcn_PT_master(st_master)

i1 = 1;
for ii=i1:length(st_master)
	wswb_export_nearby_ghcn_PT(st_master,ii);
end