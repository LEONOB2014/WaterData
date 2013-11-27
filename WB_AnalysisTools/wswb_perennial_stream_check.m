function frac_dry_years = wswb_perennial_stream_check(ws_list, dir_master)

% WSWB_PERENNIAL_STREAM_CHECK(ws_list, dir_master) checks the fraction of
% years that a stream goes dry
%
% INPUTS
% ws_list	= list of watersheds, relative paths to watershed dirs below dir_master
% dir_master= absolute path to watershed master directory
%
% OUTPUTS
% frac_dry_years = fraction of years that R goes to 0 at some point
%
% TC Moran UC Berkeley 2013

if nargin < 2
	dir_master = WB_PARAMS('dir_master');
end
if nargin < 1
	ws_list = WB_PARAMS('wslist_CA219');
end

fid = fopen(fullfile(dir_master,ws_list));
Cdir = textscan(fid,'%s','Headerlines',1);
Cdir = Cdir{1};
fclose(fid);

for cc = 1:length(Cdir)
	cdir = fullfile(dir_master,Cdir{cc},'GAGE_RUNOFF');
	Rwy = dlmread(fullfile(cdir,'RUNOFF_QGAGE_yr_R_ndays.txt'),'\t',1,0);
	Rmo = dlmread(fullfile(cdir,'RUNOFF_QGAGE_yr_mo_R.txt'),'\t',1,0);
	nchk = Rwy(:,end)>360;
	Rmo = Rmo(nchk,2:end-1);
	R0chk = sum(Rmo==0,2) > 0;
	frac_dry_years(cc) = sum(R0chk)/length(R0chk);
end

xx = 1;