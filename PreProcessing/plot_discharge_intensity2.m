function plot_discharge_intensity2(st_runoff, site_code)

% PLOT_DISCHARGE_INTENSITY produces a color intensity plot of the daily
% mean discharge for all years and days of data

% ------------------
% ***** Plot All Day, Year data (not just valid years)

%% EXTRACT VARIABLES FROM STRUCTURE
st = st_runoff;

% Check for number of data days for each year
years = st.water_years;
num_yrs = length(years);
ndays = size(st.Q_mean_daily_wy_m3s,2);
days = 1:ndays;

% check whether any years are missing
years_cont = years(1):years(end);
cont_chk = ~ismember(years_cont, years);
idx_miss = find(cont_chk);
row_nan = NaN(1,366);

% insert NaN rows where continuous years are missing
Qdata = st.Q_mean_daily_wy_m3s;
for ii = 1:length(idx_miss)
    this_idx_miss = idx_miss(ii);
    Qdata_new = NaN((size(Qdata,1)+1),size(Qdata,2));
    Qdata_new(1:(this_idx_miss-1),:) = Qdata(1:(this_idx_miss-1),:);
    Qdata_new((this_idx_miss+1):end,:) = Qdata(this_idx_miss:end,:);
    Qdata = Qdata_new;
    
end %for ii
Qdata_m3s_cont = Qdata;

[day_grid, year_grid] = meshgrid(days, years_cont);
%% Add NaN buffer for pcolor plotting

% first add extra day, year row and column at end of day, year arrays
day_grid = [day_grid; day_grid(end,:)];
day_grid = [day_grid, (max(day_grid(:))+1)*ones(size(day_grid,1),1)];
year_grid = [year_grid; (max(year_grid(:))+1*ones(1,size(year_grid,2)))];
year_grid = [year_grid, year_grid(:,end)];

% put NaN row at end
Qdata_m3s_nan = [Qdata_m3s_cont; NaN(1,size(Qdata_m3s_cont,2))];
% put NaN column at end
Qdata_m3s_nan = [Qdata_m3s_nan, NaN(size(Qdata_m3s_nan,1),1)];

%% INTENSITY PLOT OF DAILY MEAN DISCHARGE (CFS)
hfig = figure;
hold on
hp = pcolor(day_grid, year_grid, Qdata_m3s_nan);
set(hp, 'edgecolor','none');
set(gca,'FontSize',14)

% Use mean and stddev to set intensity axis
mean_meanD = nanmean(Qdata);
std_meanD  = std(Qdata(~isnan(Qdata)));
minD = 0;
maxD = 3*std_meanD;
caxis([minD, maxD]);

% overlay intensity plot with black when flow = 0
no_flow_chk = Qdata_m3s_nan <= 0;
Qdata_no_flow = Qdata_m3s_nan;
Qdata_no_flow(~no_flow_chk) = NaN;
hs = surface(day_grid, year_grid, Qdata_no_flow, Qdata_no_flow);
set(hs, 'edgecolor','none', 'facecolor','k');

% Colorbar and labeling
colorbar
xticks = [1, 32, 62, 93, 124, 152, 183, 213, 244, 274, 305, 336];
xtick_label = {'Oct';'Nov';'Dec';'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep'};
set(gca,'XTick',xticks,'XTickLabel',xtick_label,'TickDir','out');
xlabel('Day of Water Year')
ylabel('Water Year')
site_code_str = num2str(site_code);
title({['Site Code ', site_code_str, ': ', st.site_name];'Daily Mean Discharge Rate (m^3/sec)'})
axis tight

saveas(hfig,'Discharge_Intensity_YearDay.fig');
close(hfig);



% debugging line
xx = 1;