function [hp,hf] = pcolor2(Z)

% PCOLOR2(Z) adds a buffer row and column to Z for plotting in pcolor

c = size(Z,2);
Z = [Z;NaN(1,c)];
r = size(Z,1);
Z = [Z,NaN(r,1)];
hf = figure;
hp = pcolor(Z);
set(hp,'edgecolor','none')
colorbar
