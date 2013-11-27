function Dvec = daily2vec(Dday,dcy)

%  make single vector for Dday, removing non-leap-year NaNs at day 366
Dvec = nan(1,numel(Dday));
dd = 1;
for yy = 1:length(dcy)
	if ~isleapyear(dcy(yy))
		ndays = 365;
	else
		ndays = 366;
	end
	Dvec(dd:dd+ndays-1) = Dday(yy,1:ndays);
	dd = dd+ndays;
end