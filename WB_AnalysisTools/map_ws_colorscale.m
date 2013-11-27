function map_ws_colorscale(dir_ws, d, st_dscale, st_cmap_type, hf)


%% Data Interval
dmin = st_dscale.dmin;
dmax = st_dscale.dmax;
dstep= st_dscale.dstep;

dvec = dmin:cval:dmax;
n = length(dvec);

%% Colormap
cmap_func = st_cmap_type.cmap_func;
cmap_type = st_cmap_type.cmap_type;
if strcmp(cmap_func,'colormap')
	cmap = eval([cmap_type,'(',num2str(n),')']);
elseif strcmp(cmap_func,'lbmap')
	cmap = lbmap(n,cmap_type);
elseif strcmp(cmap_func,'colormapTCM')
	cmap = colormapTCM(cmap_type);
end

% Notes
% put watersheds on map any color
% see 'patch' doc for how to set Cdata for each patch
%	nan = transparent
% allows dynamic adjustment of color map and scale properties afterwards

