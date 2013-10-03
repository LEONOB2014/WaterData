% script check_perennial_stream

mdir = '/Users/tcmoran/Desktop/Catchment Analysis 2011/AA_CA_Catchments_Master/GAGESII_CATCHMENTS_CA/GAGESII_CATCHMENTS_219';
flist = 'FILTERED_CATCHMENTS_219.txt';

fid = fopen(fullfile(mdir,flist));
Cdir = textscan(fid,'%s','Headerlines',1);
Cdir = Cdir{1};
fclose(fid);

for cc = 1:length(Cdir)
    cdir = fullfile(mdir,Cdir{cc},'GAGE_RUNOFF');
    cd(cdir)
    Rwy = dlmread('RUNOFF_QGAGE_yr_R_ndays.txt','\t',1,0);
    Rmo = dlmread('RUNOFF_QGAGE_yr_mo_R.txt','\t',1,0);
    nchk = Rwy(:,end)>360;
    Rmo = Rmo(nchk,2:end-1);
    R0chk = sum(Rmo==0,2);
    R0chk = R0chk > 0;
    frac_dry_years(cc) = sum(R0chk)/length(R0chk);
    
end