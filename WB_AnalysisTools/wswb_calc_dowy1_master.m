function [st_master,DOWY1,RbDOWY1,RbStdDOWY1] = wswb_calc_dowy1_master(st_master)

% WSWB_CALC_WYDAY1_MASTER(st_master) calculates the first day of the
% water year using objective criteria
%
% INPUTS
% st_master = master water balance data structure (via WB_MASTER_STRUCT3)
%
% OUTPUTS
% st_master = with first dowy
%
% TC Moran UC Berkeley 2013

%%  INITIALIZE
Nws = length(st_master);
wsz = 15;                   % data smoothing window size
quant_val = 0.8;            % DOWY1 quantile value, e.g. 0.8 = DOY before 80% of min Rb days
is_Rb = true;
% Preallocate
Oct1 = firstdayofmonth(10,2001);
DOWY1 = [nan(Nws,2),Oct1*ones(Nws,1)];
RbDOWY1   = nan(Nws,3);
RbStdDOWY1 = nan(Nws,3);
dir_master = WB_PARAMS('dir_master');

for ii = 1:Nws
	%% DATA FOR CALCS
	st = st_master(ii);
	
	% Runoff data timeline: undisturbed years
	cy_wblast = st.HYDROL_TIMELINE.WB_undisturbed_last;
	cy_lolast = st.HYDROL_TIMELINE.LowFlow_undisturbed_last;
	cy_last = min(cy_wblast,cy_lolast);
	% BASEFLOW
	Rb = st.Rb.d_cy.USGS.data;
	Rbcy = st.Rb.d_cy.USGS.year;
	Rchk = Rbcy <= cy_last;
	Rb = Rb(Rchk,:); Rbcy = Rbcy(Rchk);
	% PRECIP
	Pd = st.P.d_cy.PRISM.data;
	Pdcy = st.P.d_cy.PRISM.year;
	Pchk = Pdcy <= cy_last;
	Pd = Pd(Pchk,:); Pdcy = Pdcy(Pchk);

	%% Data for plots
	st_plot.P_daily = Pd;
	st_plot.Pcys = Pdcy;
	st_plot.pet_mo = st.PET.mo_cy.CIMIS.data;
	st_plot.dir_ws = fullfile(dir_master,st.DIR);
	st_plot.ws_name = st.METADATA.ws.GAGESII.BASINID.STANAME;
	st_plot.id = st.ID;
	
	%% Calculate DOWY1
	[Dowy1,RbDowy1,RbStdDowy1] = wswb_calc_dowy1(Rb,Rbcy,is_Rb,wsz,quant_val,st_plot);
	
	%% ADD TO ST_MASTER
	% DOWY1 Median
	jj = 1;
	WYday1.MedMinRbDOY.docy = Dowy1(jj);
	WYday1.MedMinRbDOY.RbMean = RbDowy1(jj);
	WYday1.MedMinRbDOY.RbStd = RbStdDowy1(jj);
	WYday1.MedMinRbDOY.note = 'Median DOY of min yearly Rb';
	% DOWY1 Quant
	jj = 2;
	WYday1.QuantMinRbDOY.docy = Dowy1(jj);
	WYday1.QuantMinRbDOY.RbMean = RbDowy1(jj);
	WYday1.QuantMinRbDOY.RbStd  = RbStdDowy1(jj);
	WYday1.QuantMinRbDOY.quant = quant_val;
	WYday1.QuantMinRbDOY.note = 'DOY that precedes quant fraction of yearly min Rb DOY';
	% DOWY1 Oct 1
	jj = 3;
	WYday1.Oct1.docy = Oct1;
	WYday1.Oct1.RbMean = RbDowy1(jj);
	WYday1.Oct1.RbStd  = RbStdDowy1(jj);
	WYday1.Oct1.note = 'October 1 as DOWY1';
		
	st_master(ii).WYday1 = WYday1;
	
	DOWY1(ii,:) = Dowy1;
	RbDOWY1(ii,:) = RbDowy1;
	RbStdDOWY1(ii,:) = RbStdDowy1;
	
	if Nws > 1,	display([num2str(100*ii/Nws),'% done']), end
end

