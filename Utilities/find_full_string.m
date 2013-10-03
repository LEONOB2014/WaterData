function full_string = find_full_string(string_list, str_include, str_exclude)

% FIND_FULL_STRING searches string_list for multiple string match
% requirements and returns the full string(s) that meet all requirements.
% Output 'full_string' must include all strings in str_include and exclude
% all strings in str_exclude.
%
% INPUTS
% string_list = cell array of text strings to search
% str_include = cell array of text strings that must be present in full string
% str_exclude = cell array of text strings that must be absent from full string
%
% OUTPUTS
% full_string = cell array of strings from string_list that satisfy requirements
%
% Thomas Moran
% UC Berkeley, 2010

% if str_exclude omitted
if nargin < 3
    str_exclude = [];
end %if nargin

num_in = length(str_include);
num_ex = length(str_exclude);
num_strings = length(string_list);

nn = 1;
% cycle through string list
for ss = 1:num_strings
    this_string = string_list{ss};
    
    %check for all required text first
    for in = 1:num_in
        this_in = str_include{in};
        chk_this_in = strfind(this_string, this_in);
        
        % if any require text isn't found move to next string
        if isempty(chk_this_in)
            break
            
        % if all required text is found, move to excluded strings
        elseif in == num_in
            
            chk_ex = 1;
            % cycle through excluded strings
            for ex = 1:num_ex
                this_ex = str_exclude{ex};
                chk_this_ex = strfind(this_string, this_ex);
                
                % if any excluded text is found move to next string
                if ~isempty(chk_this_ex)
                    chk_ex = 0;
                    break
                end % if isempty
                              
            end %for ex
            
            if chk_ex == 1 
                % SHOULD ONLY REACH THIS POINT IF BOTH INCLUSIONS AND EXCLUSIONS
                % SATISFIED
                full_string{nn} = this_string;
                nn = nn+1;
            end % if chk_ex
            
            
        end %if isempty
        
    end %for in
    
end %for ss

% if no result, return empty array
if nn == 1
    full_string = [];
end %if 