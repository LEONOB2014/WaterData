function U = baseflow_filter(Q,a)

% BASEFLOW_FILTER(Q,a) filters baseflow U from daily mean streamflow Q
% using the one parameter recursive filter described in Voepel et al. 2011.
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
% a = filter parameter (0.925 default)
%
% OUTPUTS
% U = mean daily base flow vector
%
% TC Moran UC Berkeley 2013

%% INITIALIZE
if nargin < 2
    a = 0.925;  % default value, per Voepel
end
if min(size(Q))==1
    Case = 'VECTOR';
else
    nyrs = size(Q,1);
    Case = 'YEARLY';
end

%% SWITCH BY CASE
switch Case
    case 'VECTOR'
        U = nan(size(Q));
        % neglect nans
        nchk = ~isnan(Q);
        QQ = Q(nchk);
        UU = filter_1param_recursive(QQ,a);
        U(nchk) = UU;
    case 'YEARLY'
        U = nan(size(Q));
        for yy = 1:nyrs
            q = Q(yy,:);
            % if isnan(q(end)),q = q(1:end-1); end % eliminate leap year nans
            % neglect nans for now
            nchk = ~isnan(q);
            qq = q(nchk);
            uu = filter_1param_recursive(qq,a);
            U(yy,nchk) = uu;
        end
end

% %% PLOT
% figure, hold on
% QT = Q'; UT = U';
% plot(QT(:))
% plot(UT(:),'r')
% xlabel('day')
% ylabel('Mean Flow')
% title('Total Stream Flow and Base Flow vs Time')
% legend('Total','Base')
% box on


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