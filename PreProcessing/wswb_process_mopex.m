function [P,R,PET,Tmax,Tmin,Cys] = wswb_process_mopex(Dmopex)

% WSWB_PROCESS_MOPEX(Dmopex) converts MOPEX daily data into variable arrays
% in [Year x docy] format
%
% [year, month, day, p, pet, r, tmax, tmin]

ymd = Dmopex(:,1:3);
d	= Dmopex(:,4:end);
d(d==-99) = nan;
% p	= Dmopex(:,4);
% pet = Dmopex(:,5);
% r	= Dmopex(:,6);
% tmax= Dmopex(:,7);
% tmin= Dmopex(:,8);

Nvars = size(d,2);
Cys = unique(ymd(:,1));
Nyrs = length(Cys);

D = nan(Nyrs,366,Nvars);

for vv = 1:Nvars
	for yy = 1:Nyrs;
		chkY = ymd(:,1) == Cys(yy);
		D(yy,1:sum(chkY),vv) = d(chkY,vv);
	end
end
P	= D(:,:,1);
PET = D(:,:,2);
R	= D(:,:,3);
Tmax= D(:,:,4);
Tmin= D(:,:,5);

xx = 1;