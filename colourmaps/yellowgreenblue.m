%% Return a colormap array [m,3] -- sequential, shades of blue.
%
%
% ARGUMENTS:
%    m -- number of colours in colormap.
%
% OUTPUT:
%    c -- [m,3] colormap array.
%
% REQUIRES:
%
% AUTHOR:
%     Paula Sanz-Leon (2018-12-21).
%
% USAGE:
%{
    
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [c] = yellowgreenblue(m, mode)
    %% If number of colours (m) not specified, try setting from current colormap.
    if nargin < 1
       f = get(groot, 'CurrentFigure');
       if isempty(f)
          m = size(get(groot, 'DefaultFigureColormap'), 1);
       else
          m = size(f.Colormap, 1);
       end
    end
    
    if nargin < 2 
        mode='dir';
    end


    %% Basis colormap from http://colorbrewer2.org 
   
    bcm = [255, 255, 217, ...
           237, 248, 177, ...
           199, 233, 180, ...
           127, 205, 187, ...
            65, 182, 196, ...
            29, 145, 192, ...
            34,  94, 168, ...
            37,  52, 148, ...
            8,   29,  88, ...
                             ] ./ 255.0;

    %% Number of colours in basis colormap.
    nc = size(bcm, 1);

    %% Colour step size to produce m colours for output.
    cstep = (nc - 1) / (m - 1);

    %% Linear interpolation of basis colormap.
    c = interp1(1:nc, bcm, 1:cstep:nc);
    
    if strcmp(mode, 'rev') % reverse colormap 
        c = c(end:-1:1, :);
    end
end % function yellowgreenblue()
