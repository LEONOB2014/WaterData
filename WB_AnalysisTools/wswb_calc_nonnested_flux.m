function X = wswb_calc_nonnested_flux(Xout,Aout,Xin,Ain)

% WSWB_CALC_NONNESTED_FLUX(Xout,Aout,Xin,Ain) calculates the weighted flux
% of variable X for the non-nested area of an outer watershed with area Aout by
% subtracting the flux of the inner nested watershed with area Ain.
%
% INPUTS
% Xout	= flux for outer, encompassing watershed [L or L/T]
% Aout	= area of outer watershed [L^2]
% Xin	= flux for inner, nested watershed [L or L/T]
% Ain	= area of inner watershed [L^2]
%
% OUTPUTS
% X		= weighed flux for non-nested area of outer watershed [L or L/T]
%
% TC Moran UC Berkeley 2013

% X = (Xout.*Aout - Xin.*Ain)./(Aout - Ain);

Vout = Xout.*Aout;
if length(Ain)==1
	Vin	 = Xin.*Ain;
else
	for ii = 1:length(Ain)
		vin(:,:,ii) = Xin(:,:,ii).*Ain(ii);
	end
	Vin = sum(vin,3);
	Ain = sum(Ain); 
end

X = (Vout-Vin)./(Aout-Ain);