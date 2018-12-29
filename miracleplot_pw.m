% Miracle Plot -- Plots a 2 panel movie of a time series and it's wavelet power spectrum
% by John Terry, and Kevin Aquino
%
% ARGUMENTS:
%    time   -- <description>
%    data   -- <description>
%    pw     -- <description>
%    frequency  -- <description>
%    fs, wvl_fc, wvl_fb -- <description>
%    speed  -- (optional) <description>
%    foi  -- (optional) <description>
%    accumulate  -- (optional) <description>
%    figure_handle -- (optional) <description>
%
% OUTPUT: 
%    <output1> -- <description>
%
% USAGE:
%{

%Construct a demo time-series
X = sin(0:(100*2*pi/2048):(100*2*pi));
X = X + sin(0:(42*2*pi/2048):(42*2*pi));
X = X + sin((1:((10-1)/2048):10) .* (0:(10*2*pi/2048):(10*2*pi)));
t = 0:(1/1024):2;

% Calculate the Continuous-Wavelet-Transform
frequency = linspace(4,104,125);
fs = 1024;
wvl_fc =  2;
wvl_fb =  5;
scaling = 1;
display_flag = true;
[c, time, f, av_pwr, norm_pwr, tw, fw] = cwtspectra(X, fs, frequency, wvl_fc, wvl_fb ,display_flag, scaling);

periodspec = [fs, wvl_fc, wvl_fb];
%Movie plot
[figure_handle] = miracleplot_pw(time,X,norm_pwr, f, periodspec, 4, [21 50 84], false)

%}
% MODIFICATION HISTORY:
%    SAK(21-03-2006) -- cleaned, added comment. 
%                    -- added optional speed, and fignum arguments

function [figure_handle] = miracleplot_pw(time,data,pw,frequency,periodspec,speed,foi,accumulate, figure_handle)
    %% Set any argument that weren't specified
    if nargin < 6 || isempty(speed)
        speed = 5;
    end
    if nargin < 7 || isempty(foi)
        foi = [2 4];
    end
    if nargin < 8 || isempty(accumulate)
        accumulate = false; % Default to not accumulating power spectra.
    end

    %% Set a grey theme with yellowgreenblue colourmap
    [precall_default_groot] = set_default_groot({'grey-ygb', 'extra-large-landscape'});

    % If using a pre-existing figure, clear it first.
    if nargin < 9 || isempty(figure_handle)
        figure_handle = figure;
    elseif isgraphics(figure_handle, 'figure')
        clf(figure_handle)
    else
        error(['SAK:', mfilename, ':BadArgs'], ...
            'figure_handle must be a valid figure handle');
    end

    % Extract spectrogram parameters
    fs = periodspec(1);
    fc = periodspec(2);
    fb = periodspec(3);

    % Resoultion of time and frequency values
    tw = fc*sqrt(fb)./(foi);
    fw = (foi)*(1/fc)*(sqrt(2/(pi^2*fb)));

    max_power = max(pw(:));
    min_power = min(pw(:)); %1;

    tw = fix( (tw/(time(2)-time(1))) /2 );
    fw = fw/2 ;
    len = length(time);
 
    MAP = colormap;
    cmap_step = size(MAP,1) / (length(pw) / speed);
    j=1;

    %Initialise top panel with time series.
    axes_311 = subplot(3, 1, 1);
    axes_311.ColorOrder = blues(length(foi));
    plot(axes_311, time, data, '-', 'Color', MAP(1, :));
    xlabel(axes_311, 'Time (s)');
    ylabel(axes_311, 'Amplitude (a.u.) ');
    hold(axes_311, 'on')
    current_time_line_311 =                 ...
        plot(axes_311,                      ...
             [time(1) time(1)],             ...
             axes_311.YLim,                 ...
             'k',                           ...
             'LineWidth', 3);

    %Initialise middle panel with power spectrum.
    axes_312 = subplot(3, 1, 2);
    axes_312.ColorOrder = blues(length(foi));
    power_spectrum_xlim = [frequency(1), frequency(end)];
    power_spectrum_ylim = [(log10(min_power) + 0.2 * (log10(max_power) - log10(min_power) )), log10(max_power)];
    axis(axes_312, [power_spectrum_xlim power_spectrum_ylim]);
    xlabel(axes_312, 'Frequency (Hz) ');
    ylabel(axes_312, ' Power (a.u.)');
    hold(axes_312, 'on')
    power_line = plot(axes_312,        ...
                      frequency,       ...
                      pw(:, 1), ...
                      'Color', MAP(1, :));

    %Initialise bottom panel with spectrogram.
    axes_313 = subplot(3, 1, 3);
    axes_313.ColorOrder = blues(length(foi));
    imagesc(axes_313, time, frequency, pw);
    xlabel(axes_313, 'Time (s)');
    ylabel(axes_313, 'Frequency (Hz) ');
    hold(axes_313, 'on')
    current_time_line_313 =     ...
        plot(axes_313,          ...
             [time(1) time(1)], ...
             axes_313.YLim,     ...
             'k',               ...
             'LineWidth', 3);

    % Plot bandwidth for frequencies of interest
    for k = 1:length(foi)
        thisfreqcolour = axes_312.ColorOrder(mod(k-1, size(axes_312.ColorOrder, 1)) + 1, :);

        rectangle(axes_312, ...
                  'Position', [foi(k)-fw(k), log10(min_power), 2*fw(k), (log10(max_power) - log10(min_power))], ...
                  'LineStyle', 'none', ...
                  'FaceColor', thisfreqcolour);
    end % for k = 1:length(foi)

    foi_time_overlays = gobjects(length(foi), 1);
    for i=1:speed:length(pw)
        % plot(axes_311, time, data, 'LineWidth',3)
        % % Clear overlay lines
        % for line_index = find(isgraphics(foi_time_overlays, 'line'))
        %     delete(foi_time_overlays(line_index))
        % end
        title(axes_311, num2str(time(i),'%7.3f'))
        % hold(axes_311, 'on')
        delete(current_time_line_311);
        current_time_line_311 =     ...
            plot(axes_311,          ...
                 [time(i) time(i)], ...
                 axes_311.YLim,     ...
                 'k',               ...
                 'LineWidth', 3);

        for k = 1:length(foi)
            thisfreqcolour = axes_313.ColorOrder(mod(k-1, size(axes_312.ColorOrder, 1)) + 1, :);
            delete(current_time_line_313);
            current_time_line_313 =     ...
                plot(axes_313,          ...
                     [time(i) time(i)], ...
                     axes_313.YLim,     ...
                     'k',               ...
                     'LineWidth', 3);
            % foi_time_overlays(k) =                         ...
            %     plot(axes_311,                             ...
            %          time(max(i-tw(k),1):min(i+tw(k),len)), ...
            %          data(max(i-tw(k),1):min(i+tw(k),len)), ...
            %          'Color', thisfreqcolour);
        end

        % If not accumulating then clear previous line.
        if ~accumulate
            delete(power_line)
        end

        % Plot this power spectrum line
        power_line = plot(axes_312,        ...
                          frequency,       ...
                          log10(pw(:,i)),  ...
                          'Color', MAP(floor(cmap_step * (j-1)) + 1, :));

        % If accumulate then update power spectrum line colour.
        if accumulate
            j = j+1;
        end

        drawnow;
    end % for i=1:speed:length(pw)

    %% Reset to the default values from before the first call.
    set_default_groot(precall_default_groot);

end % function [figure_handle] = miracleplot_pw()

function [wvlt] = cmw(fs, fb, foi, tw)
% Complex Morlet wavelet 
% This function is a dummy function to have wavelets at 
% different scales shown in the plots. The wavelet produced by this function
% does not exactly correspond to the wavlet used by cwt() in cwtspectra()

% Centre wavelet at t=0
half_point = tw/2; % in seconds
time  = -half_point:1/fs:half_point;

% Complex sine wave
sine_wave = exp(1i*2*pi*foi.*time);

% Gaussian window
s = fb/(2*pi);
gaus_win  = exp((-time.^2) ./ (2*s^2));

wvlt = sine_wave.*gaus_win;

end % function cmw()