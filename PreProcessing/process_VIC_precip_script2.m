%% Script to pre-process VIC precipitaion data

%% INITIALIZE
% data directory
Pdir = '/Users/tcmoran/Desktop/2012 Catchment Analysis/_VIC Precip/2005 study';
Ddir{1} = '/Users/tcmoran/Desktop/2012 Catchment Analysis/_VIC Precip/2005 study/vic_inputdata_gbas_1915-2003_111504';
Ddir{2} = '/Users/tcmoran/Desktop/2012 Catchment Analysis/_VIC Precip/2005 study/vic_inputdata_cali_1915-2003_111704';
% ddir = pwd; % move to data directory first
% dir_orig = cd(ddir);

% fname_format = 'data_yy.yyyy_-xxx.xxxx'; % where yy.yyyy = lat, xxx.xxxx = lon

% Grid info
pixsz = 1/8; % degrees Lat/Lon
cyears = 1915:2003;
chkleap = isleapyear(cyears);
ndayscy = 365*ones(length(cyears),1);
ndayscy(chkleap) = 366; % number of days in each calendar year
NdaysCY = [0;cumsum(ndayscy)]; % gives running count of DEC31 for each year from Jan 1, 1915

% Data format
prec = 'uint16';
mformat = 'l';

%% LOAD DAILY PRECIP DATA FOR EACH LAT/LON FILE
for dd = 1:length(Ddir)
    ddir = Ddir{dd};
    cd(ddir)
    fnames = get_file_names2(ddir,'data_');
    nfiles = length(fnames);
    for ii = 1:nfiles
        display([num2str(nfiles-ii),' TO GO'])
        fname = fnames{ii};
        lat(ii) =  str2num(fname(6:12));
        lon(ii) = str2num(fname(14:end));

        % Load file and get precip data
        fid = fopen(fname);
        D = fread(fid,inf,prec,0,mformat);
        fclose(fid);

        n = length(D); iP = 1:4:n;
        P(:,ii) = uint16(D(iP));
    end

    %% MAKE LAT/LON GRIDS
    xmin = min(lon); xmax = max(lon);
    x = xmin:pixsz:xmax;
    ymin = min(lat); ymax = max(lat);
    y = ymin:pixsz:ymax;
    [LON,LAT] = meshgrid(x,y); % grid of Lat, Lon vals
    LAT = flipud(LAT); % standard array format for this data processing is NW corner = pixel [1,1]

    %% MAKE 3D ARRAY OF PRECIP DATA
    PgridDaily = uint16(zeros(size(LON,1),size(LON,2),size(P,1))); % preallocate PgridDaily
    PgridMonthly = nan(size(LON,1),size(LON,2),length(cyears),12); % preallocate PgridMonthly

    for ii = 1:length(lon)
        display([num2str(length(lon)-ii),' TO GO'])
        [r,c] = find(LON==lon(ii) & LAT==lat(ii));
        p = P(:,ii);
        if ~isempty(r) % empty r shouldn't happen, but...
            PgridDaily(r,c,:) = p;
            % CYCLE THROUGH YEARS
            for yy = 1:length(NdaysCY)-1
                cy = cyears(yy);
                py = p(NdaysCY(yy)+1:NdaysCY(yy+1)); % data for this pixel for this cy
                % CYCLE THROUGH MONTHS
                ndaysM = daysinmonth(1:12,cy);
                NdaysM = [0,cumsum(ndaysM)];
                for mm = 1:12
                    pm = py(NdaysM(mm)+1:NdaysM(mm+1)); % data for this month of this cy
                    PM(yy,mm) = sum(double(pm));
                end
            end
            PgridMonthly(r,c,:,:) = PM;
        end
    end

    %% SAVE DATA STRUCTURES
    % YEARLY
    for yy = 1:length(cyears)
        data = squeeze(PgridMonthly(:,:,yy,:));
        data(:,:,13) = sum(data,3);
        st_grid_data.data = data;
        st_grid_data.axes = {'Lon E','Lat N','CY','Month'};
        st_grid_data.year = cyears(yy);
        st_grid_data.months = [1:13];
        st_grid_data.year_type = 'CY';
        fname = ['ST_VIC_PRECIP_CY_MONTHLY_',num2str(cyears(yy)),'.mat'];
        save(fname,'st_grid_data')
    end
    clear st_grid_data
    % TOTAL
    st_grid_data.data = PgridMonthly./40; % convert units to mm
    st_grid_data.axes = {'Lon E','Lat N','CY','Month'};
    st_grid_data.years = cyears;
    st_grid_data.grid_Lat_NAD83 = LAT;
    st_grid_data.grid_Lon_NAD83 = LON;

    save('_ST_VIC_PRECIP_CY_MONTHLY_TOTAL.mat','st_grid_data')
    if dd == 1
        Dgb = st_grid_data.data;
        gbLat = st_grid_data.grid_Lat_NAD83;
        gbLon = st_grid_data.grid_Lon_NAD83;
    elseif dd == 2
        Dca = st_grid_data.data;
        caLat = st_grid_data.grid_Lat_NAD83;
        caLon = st_grid_data.grid_Lon_NAD83;
    end
end

%% COMBINE CA AND GREAT BASIN DATA TO MAKE COMPLETE CA DATASET
cd(Pdir)
dca = squeeze(Dca(:,:,1,1));      % representative Year-Month slice of CA data grid
dgb = squeeze(Dgb(:,:,1,1));     % representative Year-Month slice of Great Basin data grid
CAchk = false(size(dca));
GBchk = false(size(dgb));
for ii = 1:size(caLat,1)
    for jj = 1:size(caLat,2)
        lon = caLon(1,jj);
        lat = caLat(ii,1);
        if isnan(dca(ii,jj)) % only look for GB cells where CA cells are empty (NaN)
            r = find(gbLat(:,1)==lat);
            c = find(gbLon(1,:)==lon);
            if ~isempty(r) && ~isempty(c)
                if ~isnan(dgb(r,c))
                    CAchk(ii,jj) = true; % mark this pixel to replace CA (NaN) with GB data
                    GBchk(r,c) = true;  % mark this GB pixel to replace CA pixel
                end
            end
        end
    end
end
%% COMBINE INTO SINGLE ARRAY SAME SIZE AS CA ARRAY
DCA = Dca;
for yy = 1:size(Dca,3)
    for mm = 1:size(Dca,4)
        dc1 = Dca(:,:,yy,mm);
        dg1 = Dgb(:,:,yy,mm);
        dc1(CAchk) = dg1(GBchk);
        DCA(:,:,yy,mm) = dc1;
    end
end

%% SAVE COMBINED ARRAY
clear st_grid_data
st_grid_data.data = DCA; % convert units to mm
st_grid_data.axes = {'Lon E','Lat N','CY','Month'};
st_grid_data.years = cyears;
st_grid_data.grid_Lat_NAD83 = caLat;
st_grid_data.grid_Lon_NAD83 = caLon;
save('_ST_VIC_PRECIP_CY_MONTHLY_TOTAL.mat','st_grid_data')

% YEARLY DATA FILES
clear st_grid_data
for yy = 1:length(cyears)
    data = squeeze(DCA(:,:,yy,:));
    data(:,:,13) = sum(data,3); % annual totals
    st_grid_data.data = data;
    st_grid_data.axes = {'Lon E'  'Lat N'  'Month'};
    st_grid_data.year = cyears(yy);
    st_grid_data.months = 1:13;
    st_grid_data.year_type = 'CY'; 
    fname = ['ST_VIC_PRECIP_CY_MONTHLY_',num2str(cyears(yy)),'.mat'];
    save(fname,'st_grid_data')
    
end