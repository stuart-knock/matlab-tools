%% Plot time-series embedded(3D) against its own 1st & 2nd derivatives.
%
%  Exploratory tool for determining(getting a feel for) a time-series'
%  embedding(3D).
%
% ARGUMENTS:
%     x -- time series in column vectors ['time', number of time-series].
%     colourmaps -- cell array of strings indicating colourmaps to use,
%                   defaults to the four *_basic colourmaps. If there are
%                   more time-series provided than colourmaps, then the
%                   time-series are plotted in batches of numel(colourmaps).
%     standardise_derivatives -- [true|false], if true, standardises derivatives
%                                to same value range as x. Default true.
%
% REQUIRES:
%     set_default_groot() -- Sets a default graphics theme from a predefined set.
%     axis_to_origin() -- Give a 3D plot axes that pass through the origin.
%     trajectory_colourmap() -- adds start and end colours to colourmap.
%     standardise_range() -- Rescales data to a specified inclusive range.
%
%     % requested colourmaps, default is:
%     blue_basic(m)  -- Return a colormap [m, 3], simple blue, dark to light.
%     red_basic(m)   -- Return a colormap [m, 3], simple red, dark to light.
%     green_basic(m) -- Return a colormap [m, 3], simple green, dark to light.
%     black_basic(m) -- Return a colormap [m, 3], simple black, dark to light.
%
% OUTPUT:
%     A figure showing a time-series embedded against its own 1st and 2nd
%     derivatives.
%
% AUTHOR:
%     Stuart A. Knock (2006-04-03).
%
% USAGE:
%{
    % Make some dummy data
    X = [sin(0:(2*pi/42):(2*pi));                           ...
         sin(0:(2*pi/42):(2*pi)) + cos(0:(2*pi/42):(2*pi)); ...
         sin(0:(4*pi/42):(4*pi)) + sin(0:(2*pi/42):(2*pi)); ...
         sin(0:(2*pi/42):(2*pi)) .* cos(0:(2*pi/42):(2*pi))].';
    % Plot time derivative embedded(3D) representations
    derivplot3(X);
    % with custom colourmaps. NOTE: three colourmaps and four time-series, so,
    %                               for each deriv two plots will be generated:
    %                               first one with the first three time series;
    %                               second on with just the final time-series.
    derivplot3(X, {'blues', 'yellowgreenblue', 'bluered'});

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [figure_handle, axes_handle] = derivplot3(x, colourmaps, standardise_derivatives)
    %% Set any argument that weren't specified
    if nargin < 1 || isempty(x)
      error(['SAK:', mfilename, ':BadArgs'], ...
            'you MUST at least provide a time series');
    elseif (size(x, 1) == 1)
        % handle being provided a single row vector
        x = x(:);
    end
    if nargin < 2 || isempty(colourmaps)
        colourmaps = {'blue_basic', 'red_basic', 'green_basic', 'black_basic'};
    end
    if nargin < 3 || isempty(standardise_derivatives)
        standardise_derivatives = true;
    end

    tpts = size(x, 1);

    Xmin = min(x(:));
    Xmax = max(x(:));

    dx = x(2:end, :) - x(1:end-1, :);
    ddx = dx(2:end, :) - dx(1:end-1, :);
    if standardise_derivatives
       dx = standardise_range(dx, [Xmin, Xmax]);
       ddx = standardise_range(ddx, [Xmin, Xmax]);
    end
    dXmin = min(dx(:));
    dXmax = max(dx(:));
    ddXmin = min(ddx(:));
    ddXmax = max(ddx(:));

    % Convert cellarray of char into cell array of function handles.
    colourmaps = cellfun(@str2func, colourmaps, 'UniformOutput', false);
    number_of_colours = min([numel(colourmaps) size(x, 2)]);

    % Set a theme
    [precall_default_groot] = set_default_groot({'dark', 'xl-square'});
    figure_handle = figure;

    % Lazy axes creation
    dummy_scatter = scatter3(standardise_range(rand(1,42), [Xmin, Xmax]), ...
                             standardise_range(rand(1,42), [dXmin, dXmax]), ...
                             standardise_range(rand(1,42), [ddXmin, ddXmax]), ...
                             '.');
    axes_handle = gca;
    xlabel('Time-Series');
    ylabel('Derivative');
    zlabel('2nd Derivative');
    axis_to_origin();
    axis(axes_handle, 'equal')
    hold(axes_handle, 'on')

    % Cleanup
    delete(dummy_scatter)
    set_default_groot(precall_default_groot);

    line_handles = gobjects(number_of_colours, 1);
    scatter_handles = gobjects(number_of_colours, 1);

    %% Step through with ANYKEY one embedding at a time
    for series_index = 1:size(x, 2)
        colour_index = mod(series_index-1, number_of_colours) + 1;
        cmap_func = colourmaps{colour_index};
        cmap = trajectory_colourmap(cmap_func(tpts-2));

        line_colour = cmap(round(size(cmap,1)/2), :);

        %Plot the trajectory
        line_handles(colour_index) = plot3(axes_handle,               ...
                                           x(1:end-2, series_index),  ...
                                           dx(1:end-1, series_index), ...
                                           ddx(:, series_index),      ...
                                           'Color', line_colour);

        %Add dots to enable visualisation of time sequence and velocity of trajectory
        scatter_handles(colour_index) = scatter3(axes_handle,               ...
                                                 x(1:end-2, series_index),  ...
                                                 dx(1:end-1, series_index), ...
                                                 ddx(:, series_index),      ...
                                                 42,                        ...
                                                 cmap,                      ...
                                                 'filled',                  ...
                                                 'MarkerEdgeColor', line_colour);

        if mod(series_index, number_of_colours) == 0
            pause
            if series_index ~= size(x, 2)
                reset_trajectories()
            end
        end %if mod(series_index, number_of_colours) == 0
    end %for series_index = 1:size(x, 2)

    hold(axes_handle, 'off')

    function reset_trajectories()
        % Clear lines
        for line_index = find(isgraphics(line_handles, 'line'))
            delete(line_handles(line_index))
        end
        % Clear scatters
        for scatter_index = find(isgraphics(scatter_handles, 'scatter'))
            delete(scatter_handles(scatter_index))
        end
        line_handles = gobjects(number_of_colours, 1);
        scatter_handles = gobjects(number_of_colours, 1);
    end

end %function derivplot3()
