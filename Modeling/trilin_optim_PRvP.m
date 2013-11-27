function [aBb,RMS,R2,PR_Prms,R2_PR_P,R2_R_P] = trilin_optim_PRvP(P,R)

% TRILIN_OPTIM_V1(dir_catch) finds the best fit of a constrained tri-linear
% model to data observations P-R vs P
%
% INPUTS
% P = precip (pre-filtered)
% R = runoff (pre-filtered)
%
% OUTPUTS
% aBb = vector of best fit parameters [a, B, b]
%           a = value of P below which R = 0
%           B = slope parameter for a < P < b
%           b = value of P above which P-R = constant
%
% NOTES
% ETd = a + (1+B)(b-a)  if b < maxP, does not exist otherwise
%                                    (no asymptote reached for ET)
%
% TC Moran UC Berkeley 2013

%% INITIALIZE
X = P;
Y = P-R;

minX = 100;                 % min value of P for R > 0
maxX = 100*ceil(max(X)/100);% max value of P
maxx = max(X);
min_ba = 100;               % min value for b - a
da = 25; db = 25;           % vector step value for a and b
dB = 0.1;                   % vector step value for slope term B
avec = minX:da:maxX-min_ba;
Bvec = -(0:dB:1);
bvec = minX+min_ba:db:maxX;

Na = length(avec); Nb = length(bvec); NB = length(Bvec);
NX = length(X);
% figure, hold on;
ii = 1;
O = []; rms = [];
for aa = 1:Na           % vary a
    a = avec(aa);
    
    for BB = 1:NB       % vary B
        B = Bvec(BB);
        Bchk = X>a;
        y(Bchk) = -B*a + (1+B).*X(Bchk);
        
        for bb = 1:Nb   % vary b
            b = bvec(bb);
            %             if b < a + min_ba | b > maxx   % b > a + min(b-a)
            if b < a + min_ba
                continue
            end
            bchk = X>b;
            if sum(bchk) == 1, continue, end     % don't let a single data point determine ETd
            y = X;
            y(Bchk) = -B*a + (1+B).*X(Bchk);
            y(bchk) = b + B*(b-a);
            %             O(ii,:) = Y - y;                % residual meas (Y) - model (y)
            O = Y - y;
            rms(ii) = sqrt(sum(O.^2)/NX);
            aBb(ii,:) = [a, B, b];
            
            ii = ii+1;
        end
    end
    display([num2str(100*aa/Na),'% Done Optim'])
end

%% CHOOSE OPTIMAL FIT
[minRMS,iRMS] = min(rms);

% % Simply Choose smallest RMS
% aBb = aBb(iRMS,:);
% RMS = minRMS;

% % Choose among essentially identical RMS
rmschk = rms < minRMS+1;
IaBbRMS = [aBb(rmschk,:),rms(rmschk)'];

% Select larger 'a'
amax = max(IaBbRMS(:,1));
IaBbRMS = IaBbRMS(IaBbRMS(:,1) == amax,:);
[~,iRMS] = min(IaBbRMS(:,4));
aBb = IaBbRMS(iRMS,1:3);
RMS = IaBbRMS(iRMS,4);

% % Select smaller 'b'
% bmin = min(IaBbRMS(:,3));
% IaBbRMS = IaBbRMS(IaBbRMS(:,3) == bmin,:);
%
% % Select larger 'B'
% Bmax = max(IaBbRMS(:,2));
% IaBbRMS = IaBbRMS(IaBbRMS(:,2) == Bmax,:);
%
% aBb = IaBbRMS(1:3);
% RMS = IaBbRMS(4);
%
% xx = 1;

%% COEFF OF DETERMINATION R^2
% R^2 = 1- SSresid / SStotal
Ymean = mean(Y);
% total sum of squares rel to mean
SStotal = sum((Y-Ymean).^2);
% model residual sum of squares
y = X;      % first model segment
a = aBb(1); B = aBb(2); b = aBb(3);
Bchk = X > a;
y(Bchk) = -B*a + (1+B).*X(Bchk);
bchk = X > b;
y(bchk) = b + B*(b-a);
O = Y - y;
SSresid = sum(O.^2);
R2 = 1 - SSresid/SStotal;

%% P-R/P RMS
PR_Pobsv = Y./P;  % observed P-R/P
PR_Pmodel = y./P; % modeled  P-R/P
O_PR_P = PR_Pobsv - PR_Pmodel;
PR_Prms = sqrt(sum(O_PR_P.^2)/NX);

%% R^2 FOR ET/P
PR_Pobsv_mean = mean(PR_Pobsv);
SStot_PR_Pobsv = sum((PR_Pobsv-PR_Pobsv_mean).^2);
SSresid_PR_Pmod = sum(O_PR_P.^2);
R2_PR_P = 1-SSresid_PR_Pmod/SStot_PR_Pobsv;

%% R^2 for R/P
R_Pobsv = R./P;
R_Pobsv_mean = mean(R_Pobsv);
SStot_R_P = sum((R_Pobsv-R_Pobsv_mean).^2);

Rmod = P-y;
R_Pmod  = Rmod./P;
O_R_P = R_Pobsv - R_Pmod;
SSresid_R_P = sum(O_R_P.^2);
R2_R_P = 1-SSresid_R_P/SStot_R_P;

xx = 1;



%% PLOT
% hf = figure
% scatter(X,Y,'filled')
% plot_trilin_aBb(aBb,X,'k')

%  larger a is better because R ~= 0 for small P
%  smaller b is better because will include more points along ETd
%  need threshold for 'essentially similar' rms values
%  +1 ?
%  +% ?