function estimate_et0_master(dir_master)

% find parent dirs
dir_parents = get_dir_names2(dir_master,'HUC');
ndirs = length(dir_parents);

%% CYCLE THROUGH PARENT DIRECTORIES
for dd = 1:ndirs
    pdir_togo = ndirs-dd+1;
    display([num2str(pdir_togo), ' ETo Pdirs ToGo'])
    dir_parent = fullfile(dir_master,dir_parents{dd});
    estimate_et0_mult(dir_parent)
end