function hf = plot_trilin_aBb(aBb,X,Y,clr,yr)

%% INITIALIZE
if nargin < 4, clr = 'k'; end
if nargin < 5, yr = []; end
hf = figure;
hold on, axis equal, box on

%% DATA POINTS
if isempty(yr)
    scatter(X,Y,'ob','filled')
else
    scatter(X,Y,40,yr,'o','filled')
    colorbar
end

%% MODEL LINES
a = aBb(1); B = aBb(2); b = aBb(3);
Xmax = 100*ceil(max(X)/100);

x1 = [0,a]; y1 = [0,a];

x2 = [a,b];
y2max = a + (1+B)*(b-a);
y2 = [a,y2max];

x3 = [b,Xmax];
y3 = [y2max,y2max];

line(x1,y1,'LineStyle','--','Color',clr,'LineWidth',1)
line(x2,y2,'LineStyle','--','Color',clr,'LineWidth',1)
if b < max(X)
    line(x3,y3,'LineStyle','--','Color',clr,'LineWidth',1)
end

%% LABELS
xlabel('P (mm)')
ylabel('P-R (mm)')
legend('Data','Fit','Location','NorthWest')
ymax = 100*ceil(max(Y)/100);
ylim([0,ymax])
xlim([0,Xmax])
