function [cmap,code_names] = bess_igbp_colormap

cmap =...
    [0,0,1;
    0,0.250000000000000,0;
    0,0.750000000000000,0;
    0.500000000000000,0.500000000000000,1;
    0.250000000000000,0.250000000000000,1;
    0.500000000000000,0,0.500000000000000;
    0.750000000000000,0,0;
    0.500000000000000,0,0;
    1,1,0;
    0.500000000000000,0.500000000000000,0;
    1,0.500000000000000,0;
    0,0.500000000000000,0.500000000000000;
    0,1,0;
    0,0,0;
    0.750000000000000,1,0;
    1,1,1;
    0.500000000000000,0.500000000000000,0.500000000000000];

code_names = ...
    {'WAT','ENF','EBF','DNF','DBF',...
     'MF','SHC','SHO','WSA','SAV','GRA',...
     'WLD','CRO','URB','MCN','ICE','BAR'};



% code_names = ...
%     {'Water','EG Ndl For','EG BL For','DC Ndl For','DC BL For',...
%      'Mix For','Shrub Cl','Shrub Op','Sav Wood','Sav','GrassLand',...
%      'Wetlands','Crops','Urban','Crop/Nat','Cryo','Barren'};

% 0 - Water Bodies
% 1 - Evergreen Needleleaf Forests
% 2 - Evergreen Broadleaf Forests
% 3 - Deciduous Needleleaf Forests
% 4 - Deciduous Broadleaf Forests
% 5 - Mixed Forests
% 6 - Closed Shrublands
% 7 - Open Shrublands
% 8 - Woody Savannas
% 9 - Savannas
% 10 - Grasslands
% 11 - Permanent Wetlands
% 12 - Croplands
% 13 - Urban and Built-Up Lands
% 14 - Cropland/Natural Vegetation Mosaics
% 15 - Snow and Ice
% 16 - Barren