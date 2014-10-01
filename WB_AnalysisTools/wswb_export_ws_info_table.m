% wswb_export_ws_info_table
% export various watershed information in table format for further
% analysis in R
% first create or load st_master

fname_nonalp = 'FILTERED_CATCHMENTS_NONALP_LOWFLOWCHK2.txt';
fname_alp    = 'FILTERED_CATCHMENTS_ALP.txt';

dir219 = import_catchment_list('FILTERED_CATCHMENTS_219.txt');
dirNonAlp	= import_catchment_list(fname_nonalp);
dirAlp		= import_catchment_list(fname_alp);

dirAll = [dirNonAlp; dirAlp];
[~,idx219] = ismember(dirAll,dir219);		% indices of dirAll ws within dir219 (used for R indexing, simplify this...)


cellCols = {'staid','idx219','huc8','name','dir',...
			'GageLatN','GageLonE','WSCentLatN','WSCentLonE',...
			'area(km2)','mean(PET)','SnowPct',...
			'StartYrVIC','EndYrVIC','NyrsVIC',...
			'DisturbIdx','NWetDaysYrAvg',...		
			'P1','P2','P3','P4','P5','P6','P7','P8','P9','P10','P11','P12',...				% avg P/mo
			'PET1','PET2','PET3','PET4','PET5','PET6','PET7','PET8','PET9','PET10','PET11','PET12',... % avg PET/mo
			'StreamKM_KM2','StrahlerMax','MainSinuous','ArtifStreamPathPct',...				% hydrol
			'LenticPct','LenticNum','LenticDens','LenticMeanSzHa',...						% lentic bodies
			'BFIavg','DunneFlowPct','HortonFlowPct','TopWetIdx','SubsurfResDays',...		% hydrol
			'O1','O2','O3','O4','O5','O6+',...												% stream order
			'IrrigAgPct','UndevFragIdx','RoadsKm_Km2',...									% development
			'LCdev','LCforest','LCag','LCwater','LCsnow','LCbarren','LCdecid','LCevergr','LCmixedfor',...
			'LCshrub','LCgrass','LCpasture','LCcrops','LCwoodywet','LCemergwet',...			% Land Cover
			'ProtArea1','ProtArea2','ProtArea3',...											% protected areas
			'AWCavg','PermAvg','WTdepthAvg','RockDepthAvg',...								% soils
			'ElevAvg','ReliefRatioMean','SlopeAvgPct','AspectDegMean','AspectEastness','AspectNorthness'};	% topography							

mo = {'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'};
streamOrder = {'1ST','2ND','3RD','4TH','5TH','6TH'};
LCtypes = {'DEV','FOREST','PLANT','WATER','SNOWICE','BARREN','DECID','EVERGR',...
		   'MIXEDFOR','SHRUB','GRASS','PASTURE','CROPS','WOODYWET','EMERGWET'};
C = cell([length(dirAll)+1, length(cellCols)]);
C(1,:) = deal(cellCols);


for ii = 2:length(C)
	idx = find(ismember({st_master(:).DIR},dirAll{ii-1}));
	st = st_master(idx);
	stm= st.METADATA.ws.GAGESII;
	
	jj = 1;		C{ii,jj}= st.ID;							% staid
	jj=jj+1;	C{ii,jj}= idx219(ii-1);						% idx219
	jj=jj+1;	C{ii,jj}= str2num(st.DIR(4:11));			% HUC8
	jj=jj+1;	C{ii,jj}= strrep(stm.BASINID.STANAME,',',''); % name (delete commas)
	jj=jj+1;	C{ii,jj}= dirAll{ii-1};						% dir
	jj=jj+1;	C{ii,jj}= stm.BASINID.LAT_GAGE;				% GageLatN
	jj=jj+1;	C{ii,jj}= stm.BASINID.LNG_GAGE;				% GageLonE
	jj=jj+1;	C{ii,jj}= stm.BAS_MORPH.LAT_CENT;			% WSCentLatN
	jj=jj+1;	C{ii,jj}= stm.BAS_MORPH.LONG_CENT;			% WSCentLonE
	jj=jj+1;	C{ii,jj}= stm.BASINID.DRAIN_SQKM;			% area(km2)
	jj=jj+1;	C{ii,jj}= mean(st.WYtot.PET.CIMIS.mo_cy.Oct1.data); % mean(PET)
	jj=jj+1;	C{ii,jj}= stm.CLIMATE.SNOW_PCT_PRECIP;		% SnowPct
				PRISMyrs = st.WB.wy.PRISM_USGS.year;
				VICyrs   = PRISMyrs(PRISMyrs > 1915 & PRISMyrs < 2004);
	jj=jj+1;	C{ii,jj}= min(VICyrs);						% StartYrVIC
	jj=jj+1;	C{ii,jj}= max(VICyrs);						% EndYrVIC
	jj=jj+1;	C{ii,jj}= length(VICyrs);					% NyrsVIC
	jj=jj+1;	C{ii,jj}= stm.BAS_CLASSIF.HYDRO_DISTURB_INDX;% DisturbIdx
	jj=jj+1;	C{ii,jj}= stm.CLIMATE.WDMAX_BASIN;			% NWetDaysYrAvg
	for kk=1:12												% P1-12 = avg monthly P
		jj=jj+1;C{ii,jj}= round(stm.CLIMATE.([mo{kk},'_PPT7100_CM'])*10);	
	end
	for kk=1:12												% PET1-12 = avg monthly PET
		jj=jj+1;C{ii,jj}= round(mean(st.PET.mo_cy.CIMIS.data(2:7,kk))); 	
	end
	jj=jj+1;	C{ii,jj}= stm.HYDRO.STREAMS_KM_SQ_KM;		% StreamKM_KM2
	jj=jj+1;	C{ii,jj}= stm.HYDRO.STRAHLER_MAX;			% StrahlerMax
	jj=jj+1;	C{ii,jj}= stm.HYDRO.MAINSTEM_SINUOUSITY;	% MainSinuous
	jj=jj+1;	C{ii,jj}= stm.HYDRO.ARTIFPATH_PCT;			% ArtifStreamPathPct
	jj=jj+1;	C{ii,jj}= stm.HYDRO.HIRES_LENTIC_PCT;		% LenticPct
	jj=jj+1;	C{ii,jj}= stm.LANDSCAPE_PAT.HIRES_LENTIC_DENS;		% LenticNum
	jj=jj+1;	C{ii,jj}= stm.LANDSCAPE_PAT.HIRES_LENTIC_MEANSIZ;	% LenticDens
	jj=jj+1;	C{ii,jj}= stm.LANDSCAPE_PAT.HIRES_LENTIC_NUM;		% LenticMeanSzHa
	jj=jj+1;	C{ii,jj}= stm.HYDRO.BFI_AVE;				% BFIavg
	jj=jj+1;	C{ii,jj}= stm.HYDRO.PERDUN;					% DunneFlowPct
	jj=jj+1;	C{ii,jj}= stm.HYDRO.PERHOR;					% HortonFlowPct
	jj=jj+1;	C{ii,jj}= stm.HYDRO.TOPWET;					% TopWetIdx
	jj=jj+1;	C{ii,jj}= stm.HYDRO.CONTACT;				% SubsurfResDays
	for kk=1:5												% O1-05 = stream order (percent)
		jj=jj+1;C{ii,jj}= stm.HYDRO.(['PCT_',streamOrder{kk},'_ORDER']);
	end
	jj=jj+1;	C{ii,jj}= stm.HYDRO.PCT_6TH_ORDER_OR_MORE;	% 06+ steam order
	jj=jj+1;	C{ii,jj}= stm.HYDROMOD_OTHER.PCT_IRRIG_AG;	% IrrigAgPct
	jj=jj+1;	C{ii,jj}= stm.LANDSCAPE_PAT.FRAGUN_BASIN;	% UndevFragIdx
	jj=jj+1;	C{ii,jj}= stm.POP_INFRASTR.ROADS_KM_SQ_KM;	% RoadsKm_Km2
	for kk=1:length(LCtypes)								% LC classif, 2006
		jj=jj+1;C{ii,jj}= stm.LC06_BASIN.([LCtypes{kk},'NLCD06']);
	end 
	for kk=1:3												% Protected Area types: 1 = most protected
		jj=jj+1;C{ii,jj}= stm.PROT_AREAS.(['PADCAT',num2str(kk),'_PCT_BASIN']);
	end
	jj=jj+1;	C{ii,jj}= in2cm(stm.SOILS.AWCAVE)*10;		% SWCavg (mm water / mm soil)
	jj=jj+1;	C{ii,jj}= in2cm(stm.SOILS.PERMAVE)*10;		% PermAvg (mm/hr)
	jj=jj+1;	C{ii,jj}= in2cm(stm.SOILS.WTDEPAVE*12)*10;	% WTdepthAvg (mm)
	jj=jj+1;	C{ii,jj}= in2cm(stm.SOILS.ROCKDEPAVE*12)*10;% RockDepthAvg (mm)
	jj=jj+1;	C{ii,jj}= stm.TOPO.ELEV_MEAN_M_BASIN;		% ElevAvg (m)
	jj=jj+1;	C{ii,jj}= stm.TOPO.RRMEAN;					% ReliefRatioMean
	jj=jj+1;	C{ii,jj}= stm.TOPO.SLOPE_PCT;				% SlopeAvgPct
	jj=jj+1;	C{ii,jj}= stm.TOPO.ASPECT_DEGREES;			% AspectDegMean
	jj=jj+1;	C{ii,jj}= stm.TOPO.ASPECT_EASTNESS;			% AspectEastness
	jj=jj+1;	C{ii,jj}= stm.TOPO.ASPECT_NORTHNESS;		% AspectNorthness
end

cell2csv('WS_INFO_TABLE.csv',C)