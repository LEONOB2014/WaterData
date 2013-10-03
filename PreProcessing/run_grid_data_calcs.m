function run_grid_data_calcs(dir_catch, calc_type)

% RUN_GRID_DATA_CALCS(dir_grid, calc_type) calculates various data products from pre-processed
% grid data, such as mean value within boundary
%
% INPUTS
% dir_catch = full path to directory for catchment
% calc_type =
%
% TC Moran, UC Berkeley 2011

%% INITIALIZE
if nargin < 1, dir_catch = uigetdir; end
if nargin < 2
    calc_type = 'AUTO';
end % default to automatic calcs

pdir = dir_catch;
dir_orig = cd(pdir);
grid_dirs = get_dir_names2(pdir,'GRID_');

%% CYCLE THROUGH GRID DIRS
for nn = 1:length(grid_dirs)
    dir_last_grid = cd(grid_dirs{nn});
    
    %% CYCLE THROUGH GRID DATA DIRS
    grid_data_dirs = get_dir_names2(pwd, 'GRID_');
    for dd = 1:length(grid_data_dirs)
        data_weighted_mean_monthly = [];
        dir_last_data = cd(grid_data_dirs{dd});
        % load grid data structure
        fnames = get_file_names;
        str{1} = 'ST_GRID_DATA_'; str{2} = '.mat';
        data_fname = find_full_string(fnames, str);
        % only keep single result per dir... need to change for multiple instances?
        data_fname = data_fname{1};
        if ~isempty(data_fname)
            load(data_fname)
        else
            display(['No data file found in directory ',grid_dirs{nn}])
            continue
        end %if
        
        %% EXTRACT USEFUL DATA
        st = st_grid_data;
        year_type   = st.pixel_data.year_type;
        year_months = st.pixel_data.months;
        month1 = year_months(1); month12 = year_months(12);
        years       = st.pixel_data.years;
        data        = st.pixel_data.data;
        weights     = st.pixel_grid.pix_weight;
        data_units  = st.data_type.data_units;
        yr_tot_type = st.data_type.yearly_tot_type;
        
        %% DETERMINE WHICH TYPE OF CALC TO DO IF 'AUTO'
        if strcmp(calc_type,'AUTO')
            if strncmp(yr_tot_type,'code',4)
                CALC_TYPE = 'CODES_IGBP';
            else
                CALC_TYPE = 'WMEAN';
            end
        else
            CALC_TYPE = calc_type;
        end
        
        
        switch CALC_TYPE
            case 'WMEAN'
                % skip if data type is 'code' rather than something that can be averaged
                if strncmp(yr_tot_type,'code',4)
                    continue
                end
                
                %% MONTHLY AND ANNUAL WEIGHTED MEANS
                for mm = 1:13 % 13 is annual total
                    if ~isempty(years)
                        data_monthly = data(:,:,:,mm);
                    else % if data is a 3D mean of months and years
                        data_monthly = data(:,:,mm);
                    end
                    data_weighted_mean_this_month = calc_grid_weighted_mean2(data_monthly,weights);
                    data_weighted_mean_monthly(:,mm) = data_weighted_mean_this_month';
                end
                %                 else % if data is already a mean of months and years
                %                 data_monthly = data(:,:,mm);
                %                 data_weighted_mean_this_month = calc_grid_weighted_mean2(data_monthly,weights);
                %                 data_weighted_mean_monthly(:,mm) = data_weighted_mean_this_month';
                %                 end
                
                
                % save data as text file in this dir
                data_meta_txt = ['data_units ',data_units,', water_year_months ',num2str(month1),':',num2str(month12)];
                file_cols = ['Year  Monthly Weighted Mean  Col13=Annual'];
                data_monthly_wgtmean = [years, data_weighted_mean_monthly];
                fname_weighted_mean = ['GRID_DATA_',year_type,'_MONTHLY_WEIGHTED_MEAN.txt'];
                dlmwrite(fname_weighted_mean, data_meta_txt,'');
                dlmwrite(fname_weighted_mean, file_cols,'delimiter','','-append');
                dlmwrite(fname_weighted_mean, data_monthly_wgtmean,'delimiter','\t','precision','%.0f','-append');
                
            case 'CODES_IGBP'
                
                if ~strncmp(yr_tot_type,'code',4)
                    continue
                end
                
                nyears = size(data,3);
                for yy = 1:nyears
                    dyear = data(:,:,yy);
                    for cc = 1:17
                        ic = cc-1;
                        code_chk = dyear == ic;
                        code_fraction(yy,cc) = calc_grid_weighted_mean2(code_chk, weights);
                        
                    end
                end
                % save data as text file in this dir
                data_meta_txt = ['data_units ',data_units,', water_year_months ',num2str(month1),':',num2str(month12)];
                file_cols = ['Year Code_CatchmentAreaFraction(0:16)'];
                data_codes = [years, code_fraction];
                fname_codes = ['GRID_DATA_',year_type,'_CODE_AREA_FRACTION.txt'];
                dlmwrite(fname_codes, data_meta_txt,'');
                dlmwrite(fname_codes, file_cols,'delimiter','','-append');
                dlmwrite(fname_codes, data_codes,'delimiter','\t','-append');
                
                % plot code timeline
                hf = figure; hold on;
                [code_colors,code_names] = bess_igbp_colormap;
                for cc = 1:17
                    code_clr = code_colors(cc,:);
                    if sum(code_clr) == 3 % white
                        code_clr = [0,0,0];
                        plot(years,code_fraction(:,cc),'Color',code_clr,'Marker','o','MarkerFaceColor','w')
                    end
                    plot(years,code_fraction(:,cc),'Color',code_clr,'Marker','o','MarkerFaceColor',code_clr)
                end
                legend(code_names,'Location','EastOutside')
                xlabel('Year')
                ylabel('Fraction of Catchment Covered by IGBP Type')
                ylim([0,1])
                title('Catchment Land Cover: MODIS IGBP')
                box on
                % save plot
                saveas(hf,'MODIS_IGBP_CODEFRACTION_v_CY.fig')
                close(hf)
                clear code_fraction
        end % switch
        cd(dir_last_data)
    end % for grid data dirs
    cd(dir_last_grid)
end %for nn

cd(dir_orig)

xx = 1;