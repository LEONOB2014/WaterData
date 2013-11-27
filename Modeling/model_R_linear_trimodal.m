function [ceRm,ceRresid,ceP_R] = model_R_linear_trimodal(R,P,ETo,a,b)

% MODEL_R_LINEAR_TRIMODAL(R,P,ETo,a,b) models runoff R as a function 
% of P-ETo using a 3-segment linear model 
%
% 1. R = P - ETo                                            for P-ETo >= a
% 2. R = P - ETo + (b/(a-b))*(P-ETo-a)     for b < P-ETo < a
% 3. R = 0                                                      for P-ETo < b
%                                          where a = lower limit of linear segment 1
%                                                b = value where R ~= 0 consistently
%
% INPUTS
% R = annual runoff depth [Nx1]
% P = annual precip depth [Nx1]
% ETo = catchment ET for energy-limited years [scalar]
% a = lower limit of linear segment 1
% b = value of P-ETo where R ~= 0 consistently
%
% OUTPUTS
% ceRm = modeled runoff {Rm_all, Rm_lo, Rm_mid, Rm_hi}
% ceRresid = R - Rm {All, Lo, Mid, Hi}
% ceP_R = P-R {Lo, Mid, Hi}
%
% TC Moran UC Berkeley 2012

%% INITIALIZE
% Defaults
if nargin < 5, b = -300; end
if nargin < 4, a = 100; end
c = b/(a-b);

P_ETo = P - ETo;
Rm = zeros(size(P));

%% MODEL

% Low: P-ETo <= b
idx_lo = find(P_ETo<=b);
Rm(idx_lo) = 0;
Rmlo = Rm(idx_lo);
Rmlo_resid = R(idx_lo) - Rm(idx_lo);
P_Rlo = P(idx_lo) - R(idx_lo); 

% Mid: P-ETo > b, < a
idx_mid = find(P_ETo > b & P_ETo < a);
Rm(idx_mid) = P_ETo(idx_mid) + c*(P_ETo(idx_mid)-a);
Rmmid = Rm(idx_mid);
Rmmid_resid = R(idx_mid) - Rm(idx_mid);
P_Rmid = P(idx_mid) - R(idx_mid); 

% Hi: P-ETo >= a
idx_hi = find(P_ETo >= a);
Rm(idx_hi) = P_ETo(idx_hi);
Rmhi = Rm(idx_hi);
Rmhi_resid = R(idx_hi) - Rm(idx_hi);
P_Rhi = P(idx_hi) - R(idx_hi); 

%% OUTPUT
ceRm{1} = Rm;
ceRm{2} = Rmlo; ceRm{3} = Rmmid; ceRm{4} = Rmhi;
ceRresid{1} = R-Rm;
ceRresid{2} = Rmlo_resid; ceRresid{3} = Rmmid_resid; ceRresid{4} = Rmhi_resid;
ceP_R = {P_Rlo, P_Rmid, P_Rhi};
