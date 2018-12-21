%% Rescales data to a given range, defaults to [0, 1].
%
% ARGUMENTS: 
%    data -- nD array in the range  [min value,  max value]
%    new_range -- 2 element vector [min, max] with the new range.
%
% OUTPUT:
%    data -- Rescaled data in the range [min, max].
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
    if nargin < 1 || isempty(data)
        error(['PSL:' mfilename ':NoData'], ...
               'You must specify data to standardise.');
    end
    if nargin > 1 && ~isempty(new_range) && (numel(new_range) ~= 2)
        error(['PSL:' mfilename ':BadRange'], ...
               'new_range should be a two element vector.');
    end

    min_val = min(data(:));
    max_val = max(data(:));

    % Rescale to range [0,1]
    data = (data - min_val) / (max_val - min_val);

    if nargin > 1 && ~isempty(new_range)
        % Rescale to range new_range
        data = data * (new_range(2) - new_range(1)) + new_range(1);
    end

end % function standardise_range()
