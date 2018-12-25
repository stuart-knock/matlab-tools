%% Return a green first element and a red final element to a colourmap array.
%
% ARGUMENTS:
%    cmap -- [m,3] colormap array.
%
% OUTPUT:
%    cmap -- [m,3] colormap array with first and last elements modified for
%            use in trajectory plots.
%
% REQUIRES:
%
% AUTHOR:
%     Stuart A. Knock (2018-12-24).
%
% USAGE:
%{
    
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cmap] = trajectory_colourmap(cmap)
    %% If number of colours (m) not specified, try setting from current colormap.
    if nargin < 1 || isempty(cmap) || (size(cmap,1) < 3)
        error(['SAK:' mfilename ':BadArg'], ...
              'require a colour map array [m,3] with m>=3.');
    end

    cmap(1, :) = [0, 1, 0]; %Set first element green (start of trajectory).
    cmap(end, :) = [1, 0, 0]; %Set final element red (end of trajectory).

end % function trajectory_colourmap()
