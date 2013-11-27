function Dday = vec2daily(Dvec,dcy)

nyrs = length(Dvec)/366;
Dday = nan(nyrs,366);
dd = 1;
for yy = 1:nyrs
	if ~isleapyear(dcy(yy))
		ndays = 365;
	else
		ndays = 366;
	end
	Dday(yy,1:ndays) = Dvec(dd:dd+ndays-1);
	dd = dd+ndays;
end