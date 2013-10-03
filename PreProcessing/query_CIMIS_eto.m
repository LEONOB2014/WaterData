function query_CIMIS_eto

% GRAB_CIMIS_ETO_WEB retrieves CIMIS ETo (PET) data from a website and
% saves it in a local folder

%% INITIALIZE
url_home = 'http://goes.casil.ucdavis.edu/cimis/';   % top level address for data
years = 2003:2012;
months_str = {'01','02','03','04','05','06','07','08','09','10','11','12'};

fname_eto_gz = 'et0.asc.gz';
fname_eto_asc = 'et0.asc';

dir_monthly = '/Users/tcmoran/Documents/ENV_DATA/Atmosphere/PET/CIMIS Data/PET/YYYY_MM_averages';
dir_avg = '/Users/tcmoran/Documents/ENV_DATA/Atmosphere/PET/CIMIS Data/PET/LongTermAverages';

%% CYCLE THROUGH YEARS AND MONTHS
dir_orig = cd(dir_monthly);
for yy = 1:length(years)
    for mm = 1:length(months_str)
        url_str = [url_home,num2str(years(yy)),'/',months_str{mm},'/',fname_eto_gz];
        [~, status] = urlwrite(url_str,fname_eto_gz);
        if ~status, continue, end  % go back to loop if no file downloaded
        gunzip(fname_eto_gz)
        % rename unzipped file
        fname_YYYY_MM = ['CIMIS_ETo_',num2str(years(yy)),'_',months_str{mm},'.asc'];
        copyfile(fname_eto_asc,fname_YYYY_MM)
    end
end

%% ALSO GET AVERAGE VALUES
cd(dir_avg)
url_avg = 'http://goes.casil.ucdavis.edu/cimis/xxxx/';
for mm = 1:length(months_str)
    url_str = [url_avg,months_str{mm},'/',fname_eto_gz];
    [~, status] = urlwrite(url_str,fname_eto_gz);
    if ~status, continue, end  % go back to loop if no file downloaded
    gunzip(fname_eto_gz)
    % rename unzipped file
    fname_YYYY_MM = ['CIMIS_ETo_Mean_',months_str{mm},'.asc'];
    copyfile(fname_eto_asc,fname_YYYY_MM)
end

cd(dir_orig)