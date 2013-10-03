function setup_catchment_analysis3_mult(mdir)

%% MAKE LIST OF CATCHMENT DIRS
dir_orig = cd(mdir);
mdir_names = get_dir_names;

%% MAKE LIST OF PARENT DIRECTORIES
ii = 1;
for dd = 1:length(mdir_names)
    this_dname = mdir_names{dd};
    if strncmp('HUC',this_dname,3)
        par_dirs{ii} = fullfile(mdir,this_dname);
        ii = ii+1;
    end %if strncmp
end %for dd

%% CYCLE THROUGH PARENT DIRECTORIES
for mm = 1:length(par_dirs)
    pdir = par_dirs{mm};
    setup_catchment_analysis3(pdir)
end

xx = 1;