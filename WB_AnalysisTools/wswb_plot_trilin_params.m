function wswb_plot_trilin_params

% let P = mean lumped area P, G = gage meas of P
% assume linear relationship: P = c*G + d
% with parameter uncertainty: oc^2 = variance of c, od^2 = variance of d
c = 1.2;
oc = 0.1;	% stdev of c
d = -300;
od = 50;	% stdev of d

P = @(G) c*G+d;		% P(G)
oP = @(G) sqrt((G.^2)*(oc.^2) + od.^2);		% stdev of P given G
oS = @(S) S*oc./(c.^2);						% stdev of slope  

Gmax = 2000;
Pmax = P(Gmax);
% Parameter a
Ga = 500;
Pa = P(Ga);
oPa = oP(Ga);

% Parameter b
Gb = 1200;
Pb = P(Gb);
oPb = oP(Gb);

% Parameter Beta = B (mid slope)
Bg = 0.6;
Bp = Bg/c;
oPB = oS(Bp);
% Parameter K (wet slope)
Kg = 1;
Kp = Kg/c;
oKp = oS(Kp);

% *** NEED TO CALCULATE AND PLOT TRI-LIN SEGMENTS AT STDDEV BOUNDS


% segment 1
xg1 = [0,Ga];
yg1 = [0,0];
xp1 = [0,Pa];
xp1max = [0,Pa+oPa];
xp1min = [0,Pa-oPa];
yp1 = [0,0];

% segment 2
xg2 = [Ga,Gb];
yg2 = [0,(Gb-Ga)*Bg];
xp2 = [Pa,Pb];
yp2 = [0,(Pb-Pa)*Bp];
xp2max = [Pa+oPa,Pb+oPb];
xp2min = [Pa-oPa,Pb-oPb];
% yp2max = [0,(

% segment 3
xp3 = [Pb,Pmax];
yp3 = [Bp*(Pb-Pa),(Pmax-Pb)*Kp+Bp*(Pb-Pa)];
xg3 = [Gb,Gmax];
yg3 = [Bg*(Gb-Ga),(Gmax-Gb)*Kg+Bg*(Gb-Ga)];

% figure, hold on, box on
line([xg1;xg2;xg3],[yg1;yg2;yg3],'Color','k','LineWidth',2)
line([xp1;xp2;xp3],[yp1;yp2;yp3],'Color','b','LineWidth',2,'LineStyle','--')
plot([xg1;xg2;xg3],[yg1;yg2;yg3],'ko')
plot([xp1;xp2;xp3],[yp1;yp2;yp3],'ro')


