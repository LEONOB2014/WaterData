function mowy1 = dowy1_2_mowy1(dowy1)

% DOWY1_2_MOWY1(dowy1) converts first day of water year dowy1 to first
% month of water year by rounding to month with closest start date

dom1 = firstdayofmonth(1:12,2001);
[~,mowy1] = min(abs(dom1-dowy1));

