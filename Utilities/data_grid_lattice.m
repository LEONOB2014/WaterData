function [XYgrid, refmat] = data_grid_lattice(pix, ulx, uly, nrows, mcols)

% DATA_GRID_LATTICE(pix,ulx,uly,nrows,mcols) makes a generic square data grid for 
% geospatial processing
% 
% INPUTS (none)
% pix       = linear size of square pixel (length per side)
% ulx       = x coordinate of center of upper left pixel
% uly       = y coordinate of center of upper left pixel
% nrows     = total number of rows in data grid
% mcols     = total number of columns in data grid
%
% OUTPUTS
% XYgrid    = X (:,:,1) and Y (:,:,2) coords of center of each pixel in grid
%             [mcols x nrows x 2]
%             
% refmat    = Reference matrix, [x y] = [row col 1] * refmat
% 
% Thomas Moran
% UC Berkeley, 2010

% Create a generic grid lattice; Requires SQUARE GRID

% Reference Matrix, see MATLAB fcn 'makerefmat'
refmat = makerefmat(ulx, uly, pix, -pix);
% [x y] = [row col 1] * refmat

% Make row and column vectors 
Xvec = ulx + [0:mcols-1]*pix;
Yvec = uly - [0:nrows-1]*pix;

% Lat and Lon of center of each cell in grid
[Xgrid, Ygrid] = meshgrid(Xvec, Yvec);
% ** CALC CHECK: Lon and Lat grids max/min values agree with PRISM metadata

XYgrid = cat(3,Xgrid, Ygrid);


% debugging line
xx = 0;