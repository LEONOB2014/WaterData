% map CA vals from R
% first import csv file, neglecting label row
for ii=1:165, dirs{ii} = strrep(dirs{ii},'"',''); end
map_CA_watershed_data(vals,dirs,ids)

