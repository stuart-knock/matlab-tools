%% Rescales data in a given range
%
% ARGUMENTS: 
%    data   -- nD array in the range  [min value,  max value]
%    [a, b] -- 2 element vector with the new range
%
% OUTPUT:
%    data -- standardise data in the range [a, b]
%
%
% AUTHOR:
%     Paula Sanz-Leon (2018-12-21).
%
% USAGE:
%{ 
    
%}
% NOTES: See https://scikit-learn.org/stable/modules/preprocessing.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = standardise_range(data, new_range)

if narging < 2
    new_range = [0 1];
end

min_val = min(data(:));
max_val = max(data(:));

data = (data - min_val) / (max_val - min_val);
data = data * (new_range(2) - new_range(1)) + new_range(1);


end % function standardise_range