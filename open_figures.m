%% Identifies open figures from handles in graphics object array.
%
% ARGUMENTS: 
%    figure_handles -- graphics object array containg handles to figures.
%
% OUTPUT:
%    open_figure_handles -- graphics object array containg the handles from
%                           'figure_handles' that refer to currently valid
%                           figures.
%
% AUTHOR:
%     Stuart A. Knock (2018-04-23).
%
% USAGE:
%{ 
    [fig_h] = plot_multiple_figures(capturing, their, handles, in, graphics, array)
    % look at and do stuff with figures, maybe closing some...
    %Close any remaining open figures
    close(open_figures(fig_h))
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [open_figure_handles] = open_figures(figure_handles)
    open_figure_handles = figure_handles(isgraphics(figure_handles, 'figure'));
end %function open_figures()
