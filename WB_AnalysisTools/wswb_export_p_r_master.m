function wswb_export_p_r_master(st_master)


% ONLY DO THIS IF NECESSARY, TAKES A LOOONG TIME
if nargin<1, st_master=WSWB_MASTER_STRUCT; end


Nws = length(st_master);
for ii=1:Nws
	wswb_export_p_r(st_master,ii)				% PRISM & VIC
	wswb_export_pGage_r(st_master,ii)		% GHCN gage obsv
	display([num2str(100*ii/Nws),'% done'])
end
