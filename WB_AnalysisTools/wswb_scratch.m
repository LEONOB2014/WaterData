% wswb_scratch

for ii = 1:219
	st = st_master(ii);
	if isfield(st.WB,'MedMinRbDOY')
		Dy{1} = st.WB.Oct1.PRISM_USGS.Pwys;
		Dy{2} = st.WB.Oct1.PRISM_USGS.Rwys;
		[~,Dy] = common_years(Dy,Dy);
		Ny(ii,1) = length(Dy{1});
	else
		Ny(ii,1) = nan;
	end
end