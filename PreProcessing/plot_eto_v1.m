function plot_eto_v1(dir_catch)

% PLOT_ETO_RVP(DIR_CATCH) plots R vs P with an ETo 1:1 line for the
% catchment specified by 'dir_catch'
% Run filter_wb_v1 and calc_eto_v1 first

%% INITIALIZE

% import site info
st_site = import_site_info('site_info.csv',dir_catch);
sid = st_site.site_id;
sname = st_site.site_name;

% get wb data
% file names and directories
dir_wb = fullfile(dir_catch,'DATA_PRODUCTS');
fname_wbfilt    = 'FILTERED_PRDIFF_PRISMp_GAGEr.txt';
path_wbfilt     = fullfile(dir_wb,fname_wbfilt);
fname_wbunfilt  = 'PRODUCT_PRDIFF_PRISMp_GAGEr.txt';
path_wbunfilt   = fullfile(dir_wb, fname_wbunfilt);
fname_filtchk   = 'Filter_Checks.txt';
path_filtchk    = fullfile(dir_wb,fname_filtchk);
path_eto        = fullfile(dir_wb,'ETo_FiltVals.txt');

% file to save
fname_rvp = 'RvP_ETo';
path_rvp = fullfile(dir_wb,fname_rvp);
fname_ETvP = 'ETvP_ETo';
path_ETvP = fullfile(dir_wb,fname_ETvP);

%% CHECK FOR FILTERED DATA
fname_chk = get_file_names2(dir_wb,fname_wbfilt);
if isempty(fname_chk)   % first run filter checks if not already done
    filter_wb_v1(dir_catch)
end

%% IMPORT FILTERED DATA
dwb  = dlmread(path_wbfilt,'\t',1,0);   % Filtered WB data
DWB  = dlmread(path_wbunfilt,'\t',1,0); % Unfiltered WB data
fchk = dlmread(path_filtchk,'\t',1,0);  % Filter Checks [NR, Rmin, ETmin, ETmax]
fchk = logical(fchk); fchk = ~fchk;
Nchk = ~fchk(:,1);
Rminchk = logical(fchk(:,2).*Nchk);
dwbRmin =  DWB(Rminchk,:);
ETminchk= logical(fchk(:,3).*Nchk);
dwbETmin = DWB(ETminchk,:);
ETmaxchk= logical(fchk(:,4).*Nchk);
dwbETmax = DWB(ETmaxchk,:);
ETo = dlmread(path_eto,'\t',1,0);       % ETo
eto = ETo(1);

%% PLOT RvP
hf = figure;
hold on, box on, axis equal
p = dwb(:,3); r = dwb(:,4);
scatter(p,r,'ok','filled')
leg_txt = {'Filtered'};
if ~isempty(dwbRmin)
    scatter(dwbRmin(:,3),dwbRmin(:,4),'rv','filled')
    leg_txt = [leg_txt,'R<Rmin'];
end
if ~isempty(dwbETmin)
    scatter(dwbETmin(:,3),dwbETmin(:,4),'md','filled')
    leg_txt = [leg_txt,'ET<ETmin'];
end
if ~isempty(dwbETmax)
    scatter(dwbETmax(:,3),dwbETmax(:,4),'b^','filled')
    leg_txt = [leg_txt,'ET>ETmax'];
end

ymax = max(DWB(:,4))+20;
xmax = max(DWB(:,3))+20;
xlim([0,xmax]), ylim([0,ymax])
xlabel('Precip (mm)')
ylabel('Runoff (mm)')
title(['Site ',sid,' ',sname,', ETo = ',num2str(eto),'   '])

% ETo line
X = [eto,eto+ymax];
Y = [0,ymax];
line(X,Y,'Color','k','LineWidth',1,'LineStyle','--')
leg_txt = [leg_txt,'1:1'];
legend(leg_txt,'location','NorthWest')
saveas(hf,path_rvp,'fig')
saveas(hf,path_rvp,'png')
close(hf)

%% PLOT P-R v P
hf = figure;
hold on, box on, axis equal
scatter(p,p-r,'ok','filled')
leg_txt = {'Filtered'};
if ~isempty(dwbRmin)
    scatter(dwbRmin(:,3),dwbRmin(:,2),'rv','filled')
    leg_txt = [leg_txt,'R<Rmin'];
end
if ~isempty(dwbETmin)
    scatter(dwbETmin(:,3),dwbETmin(:,2),'md','filled')
    leg_txt = [leg_txt,'ET<ETmin'];
end
if ~isempty(dwbETmax)
    scatter(dwbETmax(:,3),dwbETmax(:,2),'b^','filled')
    leg_txt = [leg_txt,'ET>ETmax'];
end

ymax = max(DWB(:,2))+50;
xmax = max(DWB(:,3))+50;
xlim([0,xmax]), ylim([0,ymax])
xlabel('Precip (mm)')
ylabel('P-R (mm)')
title(['Site ',sid,' ',sname,', ETo = ',num2str(eto),'   '])

% ETo line
X = [eto,xmax];
Y = [eto,eto];
line(X,Y,'Color','k','LineWidth',1,'LineStyle','--')
line([0,eto],[0,eto],'Color','k','LineWidth',1,'LineStyle','--')
leg_txt = [leg_txt,'1:1'];
legend(leg_txt,'location','NorthWest')
saveas(hf,path_ETvP,'fig')
saveas(hf,path_ETvP,'png')
close(hf)



