function estimate_et0_mult(dir_parent)

%% INITIALIZE
catchment_dir_filter = 'CATCHMENT';
dir_catchments = get_dir_names2(dir_parent,catchment_dir_filter);
ncatch = length(dir_catchments);

%% CYCLE THROUGH CATCHMENTS
for cc = 1:ncatch
    dir_catch = fullfile(dir_parent,dir_catchments{cc});
    filter_wb_v1(dir_catch);
    calc_eto_v1(dir_catch);
    plot_eto_v1(dir_catch)
end
