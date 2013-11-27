function st = wswb_nested_fluxes(st_master,ID,stNested)


idx = find([st_master(:).ID]==ID);
eval('stM = st_master(idx);');
areaM = stM.METADATA.ws.GAGESII.BASINID.DRAIN_SQKM;

%% CYCLE THROUGH DATA TYPES
data_types = stNested.data_types;
for tt = 1:length(data_types)
	data_type = data_types{tt};
	%% GET MAIN WS DATA
	eval(['Myrs = stM.',data_type,'.year;']);
	eval(['M = stM.',data_type,'.data;']);
	
	eval(['st_type = stNested.',data_type,';'])
	%% LARGEST NESTED WS
	nID = st_type.LargestNested.id;
	nyrs = st_type.LargestNested.years;
	idx = find([st_master(:).ID]==nID);
	stN = st_master(idx);
	areaN = stN.METADATA.ws.GAGESII.BASINID.DRAIN_SQKM;
	eval(['Nyrs = stN.',data_type,'.year;']);
	eval(['N = stN.',data_type,'.data;']);
	
	%% GET COMMON DATA
	[~,iM,iN] = intersect(Myrs,Nyrs);
	Myrs = Myrs(iM); Nyrs = Nyrs(iN);
	M = M(iM,:); N = N(iN,:);
	%% EVALUATE WEIGHTED FLUX MINUS NESTED WS
	dMN = wswb_calc_nonnested_flux(M,areaM,N,areaN);
	eval(['st.LargestNested.',data_type,'.data=dMN;'])
	eval(['st.LargestNested.',data_type,'.year=Myrs;'])
	
	%% MULTI-NESTED WS
	nIDs = st_type.MultiNested.ids;
	if isempty(nIDs)
		continue
	end
	nyrs = st_type.MultiNested.years;
	[~,iM] = intersect(Myrs,nyrs);
	Myrs = Myrs(iM); M = M(iM,:); 
	NN = [];
	for nn = 1:length(nIDs)
		idx = find([st_master(:).ID]==nIDs(nn));
		stN = st_master(idx);
		areaN(nn) = stN.METADATA.ws.GAGESII.BASINID.DRAIN_SQKM;
		eval(['Nyrs = stN.',data_type,'.year;']);
		eval(['N = stN.',data_type,'.data;']);

		[~,iN] = intersect(Nyrs,nyrs);
		Nyrs = Nyrs(iN); 
		NN(:,:,nn) = N(iN,:);
	end
	dMN = wswb_calc_nonnested_flux(M,areaM,NN,areaN);
	eval(['st.MultiNested.',data_type,'.data=dMN;'])
	eval(['st.MultiNested.',data_type,'.year=nyrs;'])
	
end

xx = 1;