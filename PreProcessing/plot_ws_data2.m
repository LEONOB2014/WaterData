function plot_ws_data2(dir_catch)

%% INITIALIZE
fname_wb = 'PRODUCT_PRDIFF_PRISMp_GAGEr.txt';
fname_wb_fig = 'Catchment_ETest_P_R_v_WY';
dir_wb  = fullfile(dir_catch,'DATA_PRODUCTS');
path_wb = fullfile(dir_wb,fname_wb);
path_wb_fig = fullfile(dir_wb,fname_wb_fig);

st_site = import_site_info('site_info.csv',dir_catch);
sid = st_site.site_id;
sname = st_site.site_name;

%% WATER BALANCE DATA
dwb = dlmread(path_wb,'\t',1,0);
% neglect years with too few data days
Nmin = 355;
dwb = dwb(dwb(:,5)>=Nmin,:);

%% PLOT ET VS WY
hf1 = figure; hold on;
% ET Estimates
plot(dwb(:,1),dwb(:,2),'k','Marker','o','MarkerFaceColor','k')        % WB P-R
% Precip and Runoff
plot(dwb(:,1),dwb(:,3),'--b','Marker','x')      % WB P
plot(dwb(:,1),dwb(:,4),':r','Marker','v')       % WB R
legend('P-R','P','R','Location','NorthWest')
xlabel('Water Year')
ylabel('Depth (mm)')
if length(sname)<25, nidx = length(sname); else nidx = 25; end
title(['ET, P, R vs. Water Year: Site ',sid,' ',sname(1:nidx)])
box on
ymax = max(dwb(:,3))+50;
ylim([0,ymax])
xmin = min(dwb(:,1))-1; xmax = max(dwb(:,1))+1;
xlim([xmin,xmax])
saveas(hf1,path_wb_fig,'fig')
saveas(hf1,path_wb_fig,'png')
close(hf1)
