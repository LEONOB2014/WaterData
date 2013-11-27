function nested_matrix = wswb_nested_ws_filter(ws_nested)

Nws = length(ws_nested);
mdir = WB_PARAMS('dir_master');
%% GATHER BOUNDARY AND SITE COORDS
for dd = 1:Nws
	dir_nested = match_site_id_dir(ws_nested(dd));
	stb = load(fullfile(mdir,dir_nested,'boundary','ST_BOUNDARY_DATA.mat'));
	stb = stb.st_boundary;
	bLatLon{dd} = [stb.Lat_degN;stb.Lon_degE]'; % boundary for this catchment
	% filter boundary polygons to less than 1000 points
	while length(bLatLon{dd}) > 1000
		bLatLon{dd} = bLatLon{dd}(1:2:end,:);
	end
	sLatLon(dd,:) = [stb.ref_point.Latitude,stb.ref_point.Longitude]; % site Lat/Lon for this catchment
	% centroid is better for checking interal to boundary because some site coords have errors
	geom = polygeom(bLatLon{dd}(:,2),bLatLon{dd}(:,1));
    cLatLon(dd,:) = [geom(3),geom(2)]; % centroid of this catchment
	Area(dd) = geom(1);
	
end

%% NEGLECT SITES THAT ARE WITHIN ANY OTHER WS BOUNDARY
nested_matrix = false(Nws);
for ss = 1:Nws
% 	LatLon = sLatLon(ss,:);
	for bb = 1:Nws
		if bb == ss, continue, end
		INchkSite = inpolygon(sLatLon(ss,2), sLatLon(ss,1), bLatLon{bb}(:,2), bLatLon{bb}(:,1));
		INchkCent = inpolygon(cLatLon(ss,2), cLatLon(ss,1), bLatLon{bb}(:,2), bLatLon{bb}(:,1));
		if INchkCent	% Only valid if WS being checked is smaller than boundary WS
			if Area(ss) < Area(bb)
				INchkCent = true;
			else
				INchkCent = false;
			end
		end
		INchk = logical(max(INchkSite,INchkCent));
		nested_matrix(bb,ss) = INchk;
	end
end

xx = 1;