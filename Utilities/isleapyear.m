function ly = isleapyear(year)

% ISLEAPYEAR(YEAR) determines whether the input year is a leap year or not
%
% INPUTS
% year = year(s) to check; NNNN format, e.g. 2010
%
% OUTPUTS
% ly = logical vector of leap year checks; 1 = yes, 0 = no

num_years = length(year);

for yy = 1:num_years
    if mod(year(yy),4)==0 && mod(year(yy),100)~=0
        ly(yy) = 1;
    elseif mod(year(yy),4)==0 && mod(year(yy),100)==0 && mod(year(yy),400)==0
        ly(yy) = 1;
    else
        ly(yy) = 0;
    end %if
end %for yy
ly = logical(ly);