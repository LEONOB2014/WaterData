function [oa,ob,oK] = wswb_trilin_param_errors(Pa,Pb,K,c,d,oc,od,Rb,oRb)

% WSWB_TRILIN_PARAM_ERRORS
%
% INPUTS
% Pa, Pb	= tri-lin model a & b parameters in terms of lumped areal P
% Rb		= tri-lin model Rb param
% K			= max slope dR/dP
% c, d		= linear coefficients P = cG + d
% oc, od	= uncert in c, d --> P = (c+-oc)G + (d+-od)
% oRb		= uncert in Rb

%% ANONYMOUS FUNCTIONS
P =  @(PG) c*PG+d;							% P(G)
G =  @(PP) (PP-d)./c;						% G(P)
oP = @(G)  sqrt((G.^2)*(oc.^2) + od.^2);	% stdev of P given G
oS = @(S)  S*oc./(c.^2);					% stdev of slope 


oa = oP(G(Pa));
ob = oP(G(Pb));
oK = oS(K);

xx = 1;
