function [dS,wyear] = wswb_calc_dS_recession(Rb,cyear,dowy1,B)


rb_dowy1 = Rb(:,dowy1);
rb_dowy1(rb_dowy1==0) = nan;	% don't count years when Rb goes to 0

cymin = min(cyear); cymax = max(cyear);
Cyear = [cymin:cymax]';
[~,idxC,idxc] = intersect(Cyear,cyear);
Rb_dowy1 = nan(length(Cyear),1);
Rb_dowy1(idxC) = rb_dowy1(idxc);

dRb = diff(Rb_dowy1);			% Yearly difference in Rb
dS = -dRb/B;
wyear = Cyear(2:end);			% WY defined by CY in which WY ends