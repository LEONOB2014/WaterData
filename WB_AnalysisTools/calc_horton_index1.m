function H = calc_horton_index1(Pmonthly,Rdaily)

% CALC_HORTON_INDEX1(Pmonthly,Rdaily) calculates the yearly Horton index from precip P
% and runoff R.
% P and R must be pre-filtered
%   - include only valid data years
%   - remove excessive NaNs (e.g. one per year for non-leap okay)
% 
% H = V/W = ET/"Wetted Area" = (P-R)/(P-S) = (P-R)/(P-(R-U))
%
% Where S = surface runoff
%       U = baseflow runoff
% Following Voepel, 2011
%
% INPUTS
% Pmonthly  = pre-filtered precip WY x [WY M1 M2... M12 WYtot] (mm)
% Rdaily    = pre-filtered runoff WY x [WY D1 D2... D366] (mm)
% 
% OUTPUTS
% H         = yearly Horton Index WY x [WY H]
%
% TC Moran UC Berkeley 2013

Rwy = Rdaily(:,1);
Rdaily = Rdaily(:,2:end);
R = nansum(Rdaily,2);

Pwy = Pmonthly(:,1);
P = Pwy(:,end);

%% CALCULATE BASEFLOW
Udaily = baseflow_filter(Rdaily);

U = nansum(Udaily,2);
S = R-U;

%% CALCULATE HORTON INDEX H
H = (P-R)./(P-S);
