% This script operates on CIMIS PET (aka ETo) data to convert it from
% arcgrid format into .mat files

% dir with arcgrid data
dir_pet = '/Users/tcmoran/Desktop/2012 Catchment Analysis/CIMIS Data/PET/Monthly Averages';
% dir_pet = '/Users/tcmoran/Desktop/2012 Catchment Analysis/CIMIS Data/PET/YYYY_MM_averages';
dir_orig = cd(dir_pet);

mo_str = {'01','02','03','04','05','06','07','08','09','10','11','12'};
yrs = 2003:2010;


% Stack monthly totals in Ztot
for mm = 1:12
    mo = mo_str{mm};
    ndays = daysinmonth(mm,2001); % calc days in mo for nonleap year
    [Z,refmat] = arcgridread(['CIMIS_ETo_Mean_',mo,'.asc']);  
    Ztot(:,:,mm) = Z.*ndays;
end

Ztot(:,:,13) = sum(Ztot,3);

% Native projection for CIMIS grids is Albers Teale (California centric)
% Make Albers Teale grid
[cols,rows] = meshgrid(1:size(Z,2),1:size(Z,1));
[X,Y] = pix2map(refmat,rows,cols);

% Convert Albers Teale to geographic Lat, Lon
Xvec = reshape(X,[],1);
Yvec = reshape(Y,[],1);

% save as text file in current folder to invoke external proj command -
% this takes a bit
dlmwrite('xyvec.txt',[Xvec,Yvec],'delimiter','\t','precision','%6.2f','newline','unix')

% invoke external program invproj from proj.4
env = getenv('DYLD_LIBRARY_PATH'); % need to unset this env to run invproj
setenv('DYLD_LIBRARY_PATH')

cmd = ['! invproj +proj=aea +lat_1=34.00 +lat_2=40.50 +lat_0=0.00 +lon_0=-120.00 +x_0=0.000 +y_0=-4000000.000 +ellps=GRS80 +units=m +datum=NAD83 -f ''%.4f'' xyvec.txt'];
[~,LL] = system(cmd);
setenv('DYLD_LIBRARY_PATH',env) % return to prior env setting

LonLat = str2num(LL); % convert invproj text output to numbers
Lat = reshape(LonLat(:,2),size(Z));
Lon = reshape(LonLat(:,1),size(Z));

% save as .mat file
st_cimis_pet.monthly_pet_tot_mm = Ztot;
st_cimis_pet.grid_TealeAlbers_X = X;
st_cimis_pet.grid_TealeAlbers_Y = Y;
st_cimis_pet.grid_Lat_NAD83 = Lat;
st_cimis_pet.grid_Lon_NAD83 = Lon;

save('ST_CIMIS_CY_AVG_MONTHLY_TOT.mat','st_cimis_pet')

cd(dir_orig)

xx = 1; 