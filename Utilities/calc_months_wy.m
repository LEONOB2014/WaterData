function [months, year_type] = calc_months_wy(month1)

% CALC_MONTHS calculates month numbers for year from month1
%
% INPUTS
% month1    = first month of data year, e.g. 1 = Jan for Calendar Year
%             10 = Oct for California Water Year
%
% OUTPUTS
% months    = array of month numbers
% year_type = string identifying type of year
%             'WY' = water year (Oct-Sep)
%             'CY' = calendar year (Jan-Dec)
%             'NN' = string of first month of year for other than WY or CY
%
% TC Moran UC Berkeley 2011

% Define months in year
m = month1;
for ii = 1:12
    months(ii) = m; 
    m = m + 1;
    if m > 12; m = 1; end
end %for ii


if month1 == 10
    year_type = 'WY';
elseif month1 == 1
    year_type = 'CY';
else 
    ch_month1 = num2str(month1);
    if month1 < 10
        ch_month1 = ['0',ch_month1];
    end %if
    year_type = ['WY',ch_month1];
end %if

