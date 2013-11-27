function [Rmodel,Rresid,CE_Rresids] = trilin_RvP_calc(a,b,B,P,R)

% TRILIN_RVP_CALC(a,b,B,P,R) calculates R as a trilinear function of P
%
% INPUTS
% a		= model parameter: max P for no R (initial abstraction value)
% b		= model parameter: min P for constant ET = ETo 
% B		= (slope - 1) of R vs P for a < P < b
% P		= observed annual P
% R		= observed annual R (optional)
%
% OUTPUTS
% Rmodel	= modeled R
% Rresids	= (observed R) - (modeled R)
%
% TC Moran UC Berkeley 2013

%% INITIALIZE
if nargin < 5, R = nan(size(P)); end	% nan R obsv if not input
Rmodel = nan(size(P));
Rresid = nan(size(P));

%% DRY: P <= a,		R = 0
idry = P<=a;
Rmodel(idry) = 0;
Rresid(idry) = R(idry)-Rmodel(idry);
Rresid_dry = Rresid(idry);

%% MID: a < P < b,	R = (1-B)(P-a)
imid = a < P & P < b;
Rmodel(imid) = (-B)*(P(imid)-a);
Rresid(imid) = R(imid)-Rmodel(imid);
Rresid_mid = Rresid(imid);

%% WET: b <= P,		R = (1-B)(b-a) + (P-b)
iwet = P >= b;
Rmodel(iwet) = (-B)*(b-a) + (P(iwet)-b);
Rresid(iwet) = R(iwet)-Rmodel(iwet);
Rresid_wet = Rresid(iwet);

CE_Rresids = {Rresid_dry, Rresid_mid, Rresid_wet};

xx = 1; % debug
