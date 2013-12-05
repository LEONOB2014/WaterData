function wswb_compare_annual_P_gage_ws_master(st_master)

for ii = 1:length(st_master)
	wswb_compare_annual_P_gage_ws(st_master,st_master(ii).ID)
end

