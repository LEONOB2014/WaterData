function site_dir = make_site_dir2(st_site_info, parent_dir)

% MAKE_SITE_DIRS automatically names and creates directories for runoff and
% precip data from inputs

st = st_site_info;
site_num = st.site_id;
site_name = st.site_name;
site_parent = st.site_parent;
site_latN = st.site_latN;
site_lonW = st.site_lonW;
site_datum = st.site_datum;
ws_area_km2 = st.ws_area_km2;
site_area_LatLon = [ws_area_km2, site_latN, site_lonW];


ch_parent   = num2str(site_parent);
ch_site_num = num2str(site_num);

dir_name = ['CATCHMENT_Parent',ch_parent,'_Site',ch_site_num,'_',site_name];
% remove extraneous characters
dir_name(strfind(dir_name,'"')) = '';
dir_name(strfind(dir_name,',')) = '';
dir_name(strfind(dir_name,'.')) = '';
dir_name(strfind(dir_name,'+')) = '';
dir_name(strfind(dir_name,'(')) = '';
dir_name(strfind(dir_name,')')) = '';
dir_name(strfind(dir_name,'-')) = '_';
% replace spaces with underscore
dir_name(strfind(dir_name,' ')) = '_';
% dir_names{ss} = dir_name(2:end);

site_dir = fullfile(parent_dir,dir_name);

% Check if directory already exists, otherwise make one
if ~isdir(site_dir)
    mkdir(site_dir);
% else
%     return
end 


this_dir = cd(site_dir);
% write a text file with site area (km2) and Lat/Lon
fname1 = ['Site',ch_site_num,'_areakm2_LatLon.txt'];
dlmwrite(fname1, site_area_LatLon)
% write text file with site info from parent site info file
site_info_cols= ['site_num,site_name,site_parent,latN,lonW,datum,ws_area_km2'];
site_info_txt = [num2str(site_num),',',site_name,',',num2str(site_parent),',',...
                 num2str(site_latN),',',num2str(site_lonW),',',num2str(site_datum),',',...
                 num2str(ws_area_km2)];
fname2 = ['site_info.csv'];
dlmwrite(fname2,site_info_cols,'')
dlmwrite(fname2,site_info_txt,'-append','delimiter','')

cd(this_dir);
