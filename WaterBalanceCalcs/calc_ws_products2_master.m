function calc_ws_products2_master(mdir)

%% MAKE LIST OF PARENT DIRS
dir_orig = cd(mdir);
pdirs = get_dir_names2(mdir, 'HUC');


%% CYCLE THROUGH PARENT DIRS
for mm = 1:length(pdirs)
    pdir = fullfile(mdir,pdirs{mm});
    calc_ws_products2(pdir)
end

cd(dir_orig)