%% Return a colormap array [m,3] -- sequential, shades of blue.
%
% ARGUMENTS:
%    m -- number of colours in colormap.
%    order -- ['fwd'|'rev'] ordering of returned colormap array.
%
% OUTPUT:
%    c -- [m,3] colormap array.
%
% REQUIRES:
%
% AUTHOR:
%     Stuart A. Knock (2018-06-12).
%
% USAGE:
%{
    
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [c] = blues(m, order)
    %% If number of colours (m) not specified, try setting from current colormap.
    if nargin < 1 || isempty(m)
       f = get(groot, 'CurrentFigure');
       if isempty(f)
          m = size(get(groot, 'DefaultFigureColormap'), 1);
       else
          m = size(f.Colormap, 1);
       end
    end

    if nargin < 2  || isempty(order)
        order = 'fwd';
    end

    %% Basis colormap from http://colorbrewer2.org
    bcm = [255,247,251; ...
           236,231,242; ...
           208,209,230; ...
           166,189,219; ...
           116,169,207; ...
            54,144,192; ...
             5,112,176; ...
             4, 90,141; ...
             2, 56, 88  ...
                           ] ./ 255.0;

    %% Number of colours in basis colormap.
    nc = size(bcm, 1);

    %% Colour step size to produce m colours for output.
    cstep = (nc - 1) / (m - 1);

    %% Linear interpolation of basis colormap.
    c = interp1(1:nc, bcm, 1:cstep:nc);

    if strcmp(order, 'rev') % reverse colormap
        c = c(end:-1:1, :);
    end

end % function blues()
