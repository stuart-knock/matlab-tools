%% Plot time delay embedded(3D) representation of a time series.
%
%  Exploratory tool for determining(getting a feel for) suitable time delay to
%  use in the embedding(3D) of a given time-series. Delay is constant between
%  successive dimensions...(TODO: SHOULD GENERALISE).
%
% ARGUMENTS:
%     x -- time series in column vectors ['time', 'number of time-series'].
%     delay_range -- range of delays to look at FORMAT => [begin step end]
%     colourmaps -- cell array of strings indicating colourmaps to use,
%                   defaults to the four *_basic colourmaps. If there are
%                   more time-series provided than colourmaps, then the
%                   time-series are plotted in batches of numel(colourmaps).
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
%     A figure showing a series of embeddings for the given time-series...
%
% AUTHOR:
%     Stuart A. Knock (2006-08-31).
%
% USAGE:
%{
    % Make some dummy data
    X = [sin(0:(2*pi/42):(2*pi));                           ...
         sin(0:(2*pi/42):(2*pi)) + cos(0:(2*pi/42):(2*pi)); ...
         sin(0:(4*pi/42):(4*pi)) + sin(0:(2*pi/42):(2*pi)); ...
         sin(0:(2*pi/42):(2*pi)) .* cos(0:(2*pi/42):(2*pi))].';
    % Plot time delay embedded(3D) representations
    delayplot3(X);
    % with custom colourmaps. NOTE: three colourmaps and four time-series, so,
    %                               for each delay two plots will be generated:
    %                               first one with the first three time series;
    %                               second on with just the final time-series.
    delayplot3(X, [], {'blues', 'yellowgreenblue', 'bluered'});
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [figure_handle, axes_handle] = delayplot3(x, delay_range, colourmaps)
    %% Set any argument that weren't specified
    if nargin < 1 || isempty(x)
      error(['SAK:', mfilename, ':BadArgs'], ...
            'you MUST at least provide a time series');
    elseif (size(x, 1) == 1)
        % handle being provided a single row vector
        x = x(:);
    end
    if nargin < 2 || isempty(delay_range)
        delay_range = [1 2 10];
    end
    if nargin < 3 || isempty(colourmaps)
        colourmaps = {'blue_basic', 'red_basic', 'green_basic', 'black_basic'};
    end

    % Convert cellarray of char into cell array of function handles.
    colourmaps = cellfun(@str2func, colourmaps, 'UniformOutput', false);

    number_of_colours = min([numel(colourmaps) size(x, 2)]);

    tpts = size(x, 1);

    Xmin = min(x(:));
    Xmax = max(x(:));

    AxisMin = sign(Xmin)*(sqrt(3*Xmin^2));
    AxisMax = sign(Xmax)*(sqrt(3*Xmax^2));

    % Set a theme
    [precall_default_groot] = set_default_groot({'dark', 'xl-square'});
    figure_handle = figure;

    % Lazy axes creation
    dummy_scatter = scatter3(standardise_range(rand(1,42), [AxisMin, AxisMax]), ...
                             standardise_range(rand(1,42), [AxisMin, AxisMax]), ...
                             standardise_range(rand(1,42), [AxisMin, AxisMax]), ...
                             '.');
    axes_handle = gca;
    axis_to_origin();
    axis(axes_handle, 'equal')
    hold(axes_handle, 'on')

    % Cleanup
    delete(dummy_scatter)
    set_default_groot(precall_default_groot);

    line_handles = gobjects(number_of_colours, 1);
    scatter_handles = gobjects(number_of_colours, 1);

    %% Step through with ANYKEY one embedding at a time
    delays = delay_range(1):delay_range(2):delay_range(3);
    for delay = delays
        title(axes_handle, strcat('Delay in Data-pts = ',' ', num2str(delay)));

        for k = 1:size(x, 2)
            colour_index = mod(k-1, number_of_colours) + 1;
            cmap_func = colourmaps{colour_index};
            cmap = trajectory_colourmap(cmap_func(tpts - (2*delay)));

            line_colour = cmap(round(size(cmap,1)/2), :);

            %Plot the trajectory
            line_handles(colour_index) = plot3(axes_handle,             ...
                                               x(1:end-2*delay, k),     ...
                                               x(1+delay:end-delay, k), ...
                                               x(1+2*delay:end, k),     ...
                                               'Color', line_colour);

            %Add dots to enable visualisation of time sequence and velocity of trajectory
            scatter_handles(colour_index) = scatter3(axes_handle,             ...
                                                     x(1:end-2*delay, k),     ...
                                                     x(1+delay:end-delay, k), ...
                                                     x(1+2*delay:end, k),     ...
                                                     42,                      ...
                                                     cmap,                    ...
                                                     'filled',                ...
                                                     'MarkerEdgeColor', line_colour);

            if mod(k, number_of_colours) == 0
                pause
                if delay ~= delays(end)
                    reset_trajectories()
                end
            end %if mod(k, number_of_colours) == 0
        end %for k = 1:size(x, 2)
        if delay ~= delays(end)
            if mod(k, number_of_colours) ~= 0
                pause
            end
            reset_trajectories()
        end

    end %for delay = delay_range(1):delay_range(2):delay_range(3)
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

end %function delayplot3()
