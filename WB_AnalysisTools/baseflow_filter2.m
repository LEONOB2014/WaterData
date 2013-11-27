function U = baseflow_filter2(Q,Qcys,a)

% BASEFLOW_FILTER2(Q,cys,a) filters baseflow U from daily mean streamflow Q
% using the one parameter recursive filter described in Voepel et al. 2011.
% Differs from BASEFLOW_FILTER in that this function requires that if Q is
% an array of daily values for multiple years the format must be calendar
% years and Qcys is required.
%
%   U(t) = a*U(t-1) + ((1-a)/2)*(Q(t)+Q(t-1))
%   U(t) = U(t) <= Q(t)
%
% where 'a' is a filter parameter. Voepel uses a = 0.925 and passes the
% filter twice, once forward and once backward.
%
% Ref
% Quantifying the role of climate and landscape characteristics on hydrologic
% partitioning and vegetation response, Voepel et al., WRR, 2011
%
% INPUTS
% Q = mean daily stream flow vector [1 x days] or yearly array [years x 366]
% Qcys = vector of calendar years that correspond to rows of Q
% a = filter parameter (0.925 default)
%
% OUTPUTS
% U = mean daily base flow vector or array
%
% TC Moran UC Berkeley 2013

%% INITIALIZE
if nargin < 3
    a = 0.925;  % default value, per Voepel
end

if min(size(Q)) == 1
	Qvec = Q;
else
	Qvec = daily2vec(Q,Qcys);	% reshape array to vector, removing leap year nans
end

%% FILL REMAINING NANS
QQ = fillnans_interp(Qvec);	% fill nans with interpolated values
QQ(QQ<0) = 0;				% no negative values for Q (from interpolation)

%% RUN FILTER FOWARD AND BACK
U = filter_1param_recursive(QQ,a);

%% RESHAPE TO ARRAY IF NECESSARY
if min(size(Q)) > 1
	U = vec2daily(U,Qcys);	% reshape array to vector, removing leap year nans
end
U(isnan(Q)) = nan;			% replace NaNs from input data

%% FILTER FUNCTION
function u = filter_1param_recursive(q,a)
%% RUN FILTER FORWARD
nq = length(q);
u = zeros(size(q));
for t = 2:nq
    u(t) = a*u(t-1) + ((1-a)/2)*(q(t)+q(t-1));
    if u(t) > q(t)
        u(t) = q(t);
    end
end

%% RUN FILTER BACKWARD
for tt = 1:nq-1
    t = nq-tt+1;
    u(t) = a*u(t-1) + ((1-a)/2)*(q(t)+q(t-1));
    if u(t) > q(t)
        u(t) = q(t);
    end
end
