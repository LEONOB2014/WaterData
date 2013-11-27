function trilin_optim_list(flist,mdir)

%% INITIALIZE
if nargin < 1
    flist = 'FILTERED_CATCHMENTS_219.txt';
end
if nargin < 2
    mdir = '/Users/tcmoran/Desktop/Catchment Analysis 2011/AA_CA_Catchments_Master/GAGESII_CATCHMENTS_CA/GAGESII_CATCHMENTS_219';
end
plist = fullfile(mdir,flist);

% import list
fid = fopen(plist);
Clist = textscan(fid,'%s','headerlines',1); Clist = Clist{1};
fclose(fid);
nc = length(Clist);


%% CYCLE THROUGH CATCHMENTS IN LIST
for cc = 1:nc
    cdir = Clist{cc};
    % filter data
    [~,filtChks] = filter_wb_v2(fullfile(mdir,cdir));
    fchk = logical(prod(double(filtChks),2));
    fchkETlo = logical(filtChks(:,1).*~filtChks(:,2));
    fchkEThi = logical(filtChks(:,1).*~filtChks(:,3));
    sid  = cdir(42:49);
    ddir = fullfile(mdir,cdir,'DATA_PRODUCTS');
    pwb  = fullfile(ddir,'PRODUCT_PRDIFF_PRISMp_GAGEr.txt');
    % load wb data
    dwb = dlmread(pwb,'\t',1,0);
    Dwb = dwb(fchk,:);
    dwb_etlo = dwb(fchkETlo,:);
    dwb_ethi = dwb(fchkEThi,:);
    %     Dwb = filter_Rdays(Dwb,355);
    R = Dwb(:,4); P = Dwb(:,3);
    [aBb, RMS, R2_R, PR_Prms, R2_PR_P,R2_R_P] = trilin_optim_PRvP(P,R);
    a = aBb(1); B = aBb(2); b = aBb(3);
    if max(P) > b
        ETd = a + (1+B)*(b-a);
    else
        ETd = nan;
    end
    % Plot P-R vs P
    yr = [];
    hf = plot_trilin_aBb(aBb,P,P-R,'k',yr);
    scatter(dwb_etlo(:,3),dwb_etlo(:,2),'vm','filled')
    if ~isempty(dwb_ethi)
        scatter(dwb_ethi(:,3),dwb_ethi(:,2),'dr','filled')
        yl = ylim;
        if max(dwb_ethi(:,2))>yl(2)
            ylim([0,max(dwb_ethi(:,2))])
        end
        xl = xlim;
        if max(dwb_ethi(:,3))>xl(2)
            xlim([0,max(dwb_ethi(:,3))])
        end
    end
    if ~isempty(dwb_etlo) | ~isempty(dwb_ethi)
        xx = 1;
    end
    title([sid,':  a=',num2str(a),' b=',num2str(b),' B=',num2str(B),' rms=',num2str(RMS),' ETd=',num2str(ETd),' R2=',num2str(R2_R),'  '])
    pfig = fullfile(ddir,'PRvP_TriLinFit');
    saveas(hf,pfig,'fig');
    saveas(hf,pfig,'png');
    close(hf)
    % Plot R vs P
    
    
    
    display([num2str(100*cc/nc),'% done'])
    % Save text file
    txt_hdr = ['ETd(mm),a(mm),B(mm/mm),b(mm),RMSofRmodel(mm),RMSofP-R/Prms(mm),R2ofRmodel(~),R2ofP-R/P(~),R2ofR/P'];
    ETd_aBb = [ETd,a,B,b,RMS,PR_Prms,R2_R,R2_PR_P,R2_R_P];
    ptxt = fullfile(ddir,'ETo_aBb_stats.txt');
    dlmwrite(ptxt,txt_hdr,'delimiter','')
    dlmwrite(ptxt,ETd_aBb,'-append','delimiter','\t')
end