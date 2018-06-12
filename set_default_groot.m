%% Sets a default graphics theme based on predefined sets of default properties.
%
%  When setting a theme, a struct is returned containing a field for each groot
%  default value as it was prior to the call to this function. This is to enable
%  resetting to the pre-call state, so side effects can be prevented when used
%  within a plotting function.
%
%  ARGUMENTS:
%    theme -- a string indicating a predefined theme or a struct specifying a
%             complete set of default groot values. The latter case is primarily
%             intended for use in resetting to a pre-call state.
%
%  OUTPUT: 
%    precall_default_groot -- a struct containing default groot values that were
%                             set before calling this function. When calling with
%                             a predefined theme (eg. 'dark') you must capture
%                             this output to be able to undo the changes.
%
%  AUTHOR:
%    Paula Sanz-Leon (2017-12-04).
%    Stuart A. Knock (2017-12-13).
%
%  USAGE:
%{
    %% Set a dark theme
    [precall_default_groot] = set_default_groot('dark');

    %plot things using this theme

    %% Reset to the default values from before the first call.
    set_default_groot(precall_default_groot);

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [precall_default_groot] = set_default_groot(theme)
    if nargin < 1 || isempty(theme) || ~(isstruct(theme) || ischar(theme) || iscell(theme)) %
        error(['SAK:' mfilename ':BadArgs'], 'You must specify a theme.')
    end

    if (ischar(theme) || iscell(theme)) && nargout < 1 %&& ~ismember(theme, {'default', 'matlab'})
        error(['SAK:' mfilename ':NoPreStateAssignment'], ...
              'The pre-call state must be captured to enable undoing changes.');
    end

    % Capture the pre-call default groot state.
    precall_default_groot = get(groot, 'default');

    %% Set the default groot values based on struct with fields.
    if isstruct(theme)
        % Remove all current, user set, default groot values.
        precall_default_fields = fieldnames(precall_default_groot);
        for index = 1:length(precall_default_fields)
            set(groot, precall_default_fields{index}, 'remove');
        end

        %TODO(stuart-knock): Add some checks that the provided theme struct
        %                    is actually the result of a previous call to
        %                    get(groot, 'default').
        theme_default_fields = fieldnames(theme);

        % Set default groot values based on input struct.
        for index = 1:length(theme_default_fields)
            this_default = theme_default_fields{index};
            set(groot, this_default, theme.(this_default));
        end
        return
    end %isstruct(theme)

    %Meta themes
    if ischar(theme)
        switch lower(theme)
            case 'paper'
                theme = {'light', 'a4-landscape'};
            case 'presentation'
                theme = {'dark', 'medium-landscape'};
            otherwise
                theme = {theme};
        end %switch lower(theme)
    end %

    for tk = 1:numel(theme)
        %% Apply the default groot values for the requested theme.
        switch lower(theme{tk})
            % Colour themes
            case 'dark'
                %% Set a dark theme.
                set(groot, 'defaultFigureColor',   [ 31.875,  31.875,  31.875] ./ 255);
                set(groot, 'defaultAxesColor',     [ 31.875,  31.875,  31.875] ./ 255);
                set(groot, 'defaultAxesYColor',    [191.25,  191.25,  191.25]  ./ 255);
                set(groot, 'defaultAxesXColor',    [191.25,  191.25,  191.25]  ./ 255);
                set(groot, 'defaultTextColor',     [191.25,  191.25,  191.25]  ./ 255);
                set(groot, 'defaultAxesGridColor', [ 63.75,   63.75,   63.75]  ./ 255);
                set(groot, 'defaultAxesBox',       'on');
                set(groot, 'defaultFigureInvertHardcopy',    'off');

            case 'light'
                %% Set a light theme.
                set(groot, 'defaultAxesColor',     [255, 255, 255] ./ 255);
                set(groot, 'defaultAxesYColor',    [  0,   0,   0] ./ 255);
                set(groot, 'defaultAxesXColor',    [  0,   0,   0] ./ 255);
                set(groot, 'defaultFigureColor',   [255, 255, 255] ./ 255);
                set(groot, 'defaultTextColor',     [  0,   0,   0] ./ 255);
                set(groot, 'defaultAxesGridColor', [ 26,  26,  26] ./ 255);
                set(groot, 'defaultAxesGridAlpha', 1);
                set(groot, 'defaultAxesBox',       'on');

            case {'grey', 'gray', 'winter'}
                %% Set a grey theme.
                set(groot, 'defaultFigureColor',    [ 64,  64,  64] ./ 255);
                set(groot, 'defaultAxesColor',      [ 64,  64,  64] ./ 255);
                set(groot, 'defaultAxesYColor',     [128, 128, 128] ./ 255);
                set(groot, 'defaultAxesXColor',     [128, 128, 128] ./ 255);
                set(groot, 'defaultTextColor',      [128, 128, 128] ./ 255);
                set(groot, 'defaultAxesGridColor',  [ 96,  96,  96] ./ 255);
                set(groot, 'DefaultFigureColormap', winter);
                set(groot, 'defaultAxesBox',        'off');
                set(groot, 'defaultFigureInvertHardcopy',    'off');

            case 'rand'
                %% Set a random colour theme.
                set(groot, 'defaultAxesColor',     [rand, rand, rand]);
                set(groot, 'defaultAxesYColor',    [rand, rand, rand]);
                set(groot, 'defaultAxesXColor',    [rand, rand, rand]);
                set(groot, 'defaultFigureColor',   [rand, rand, rand]);
                set(groot, 'defaultTextColor',     [rand, rand, rand]);
                set(groot, 'defaultAxesGridColor', [rand, rand, rand]);
                set(groot, 'defaultFigureInvertHardcopy',    'off');

            %Scaling/sizing themes
            case {'small', 'small-landscape'}
                set(groot, 'defaultTextFontSize',      14);
                set(groot, 'defaultAxesFontSize',      14);
                set(groot, 'defaultAxesLineWidth',      2);
                set(groot, 'defaultLineLineWidth',      2);
                set(groot, 'defaultFigureUnits',       'centimeters');
                set(groot, 'defaultFigurePosition',    [2 2 16.18 10.0]);
                set(groot, 'defaultFigurePaperUnits',  'centimeters');
                set(groot, 'defaultFigurePaperSize',   [16.18 10.0]);
                set(groot, 'defaultFigurePaperType',   '<custom>');
                set(groot, 'defaultFigurePaperOrientation',  'landscape');
                set(groot, 'defaultFigurePaperPositionMode', 'auto');

            case {'medium', 'medium-landscape'}
                set(groot, 'defaultTextFontSize',     15);
                set(groot, 'defaultAxesFontSize',     15);
                set(groot, 'defaultAxesLineWidth',     2);
                set(groot, 'defaultLineLineWidth',     2);
                set(groot, 'defaultFigureUnits',      'centimeters');
                set(groot, 'defaultFigurePosition',   [2 2 24.27 15.0]);
                set(groot, 'defaultFigurePaperUnits', 'centimeters');
                set(groot, 'defaultFigurePaperSize',  [24.27 15.0]);
                set(groot, 'defaultFigurePaperType',   '<custom>');
                set(groot, 'defaultFigurePaperOrientation',  'landscape');
                set(groot, 'defaultFigurePaperPositionMode', 'auto');

            case {'large', 'large-landscape'}
                set(groot, 'defaultTextFontSize',     16);
                set(groot, 'defaultAxesFontSize',     16);
                set(groot, 'defaultAxesLineWidth',     2);
                set(groot, 'defaultLineLineWidth',     2);
                set(groot, 'defaultFigureUnits',      'centimeters');
                set(groot, 'defaultFigurePosition',   [2 2 32.36 20.0]);
                set(groot, 'defaultFigurePaperUnits', 'centimeters');
                set(groot, 'defaultFigurePaperSize',  [32.36 20.0]);
                set(groot, 'defaultFigurePaperType',   '<custom>');
                set(groot, 'defaultFigurePaperOrientation',  'landscape');
                set(groot, 'defaultFigurePaperPositionMode', 'auto');

            case {'small-protrait'}
                set(groot, 'defaultTextFontSize',      14);
                set(groot, 'defaultAxesFontSize',      14);
                set(groot, 'defaultAxesLineWidth',      2);
                set(groot, 'defaultLineLineWidth',      2);
                set(groot, 'defaultFigureUnits',       'centimeters');
                set(groot, 'defaultFigurePosition',    [2 2 10.0 16.18]);
                set(groot, 'defaultFigurePaperUnits',  'centimeters');
                set(groot, 'defaultFigurePaperSize',   [10.0 16.18]);
                set(groot, 'defaultFigurePaperType',   '<custom>');
                set(groot, 'defaultFigurePaperOrientation',  'portrait');
                set(groot, 'defaultFigurePaperPositionMode', 'auto');

            case {'medium-portrait'}
                set(groot, 'defaultTextFontSize',     15);
                set(groot, 'defaultAxesFontSize',     15);
                set(groot, 'defaultAxesLineWidth',     2);
                set(groot, 'defaultLineLineWidth',     2);
                set(groot, 'defaultFigureUnits',      'centimeters');
                set(groot, 'defaultFigurePosition',   [2 2 15.0 24.27]);
                set(groot, 'defaultFigurePaperUnits', 'centimeters');
                set(groot, 'defaultFigurePaperSize',  [15.0 24.27]);
                set(groot, 'defaultFigurePaperType',   '<custom>');
                set(groot, 'defaultFigurePaperOrientation',  'portrait');
                set(groot, 'defaultFigurePaperPositionMode', 'auto');

            case {'large-portrait'}
                set(groot, 'defaultTextFontSize',     16);
                set(groot, 'defaultAxesFontSize',     16);
                set(groot, 'defaultAxesLineWidth',     2);
                set(groot, 'defaultLineLineWidth',     2);
                set(groot, 'defaultFigureUnits',      'centimeters');
                set(groot, 'defaultFigurePosition',   [2 2 20.0 32.36]);
                set(groot, 'defaultFigurePaperUnits', 'centimeters');
                set(groot, 'defaultFigurePaperSize',  [20.0 32.36]);
                set(groot, 'defaultFigurePaperType',   '<custom>');
                set(groot, 'defaultFigurePaperOrientation',  'portrait');
                set(groot, 'defaultFigurePaperPositionMode', 'auto');

            case {'small-square'}
                set(groot, 'defaultTextFontSize',      14);
                set(groot, 'defaultAxesFontSize',      14);
                set(groot, 'defaultAxesLineWidth',      2);
                set(groot, 'defaultLineLineWidth',      2);
                set(groot, 'defaultFigureUnits',       'centimeters');
                set(groot, 'defaultFigurePosition',    [2 2 10 10]);
                set(groot, 'defaultFigurePaperUnits',  'centimeters');
                set(groot, 'defaultFigurePaperSize',   [10 10]);
                set(groot, 'defaultFigurePaperType',   '<custom>');
                set(groot, 'defaultFigurePaperOrientation',  'portrait');
                set(groot, 'defaultFigurePaperPositionMode', 'auto');

            case {'square', 'medium-square'}
                set(groot, 'defaultTextFontSize',      15);
                set(groot, 'defaultAxesFontSize',      15);
                set(groot, 'defaultAxesLineWidth',      2);
                set(groot, 'defaultLineLineWidth',      2);
                set(groot, 'defaultFigureUnits',       'centimeters');
                set(groot, 'defaultFigurePosition',    [2 2 16 16]);
                set(groot, 'defaultFigurePaperUnits',  'centimeters');
                set(groot, 'defaultFigurePaperSize',   [16 16]);
                set(groot, 'defaultFigurePaperType',   '<custom>');
                set(groot, 'defaultFigurePaperOrientation',  'portrait');
                set(groot, 'defaultFigurePaperPositionMode', 'auto');

            case {'large-square'}
                set(groot, 'defaultTextFontSize',      16);
                set(groot, 'defaultAxesFontSize',      16);
                set(groot, 'defaultAxesLineWidth',      2);
                set(groot, 'defaultLineLineWidth',      2);
                set(groot, 'defaultFigureUnits',       'centimeters');
                set(groot, 'defaultFigurePosition',    [2 2 22 22]);
                set(groot, 'defaultFigurePaperUnits',  'centimeters');
                set(groot, 'defaultFigurePaperSize',   [22 22]);
                set(groot, 'defaultFigurePaperType',   '<custom>');
                set(groot, 'defaultFigurePaperOrientation',  'portrait');
                set(groot, 'defaultFigurePaperPositionMode', 'auto');


            case {'a5', 'a5-landscape'}
                set(groot, 'defaultTextFontSize',     15);
                set(groot, 'defaultAxesFontSize',     15);
                set(groot, 'defaultLineLineWidth',     2);
                set(groot, 'defaultAxesLineWidth',     2);
                set(groot, 'defaultAxesBox',          'on');
                set(groot, 'defaultFigureUnits',      'centimeters');
                set(groot, 'defaultFigurePosition',  [2 2 21.0 14.8]);
                set(groot, 'defaultFigurePaperUnits', 'centimeters');
                set(groot, 'defaultFigurePaperType', 'a5');
                set(groot, 'defaultFigurePaperOrientation',  'landscape');
                set(groot, 'defaultFigurePaperPositionMode', 'auto');

            case {'a5-portrait'}
                set(groot, 'defaultTextFontSize',     15);
                set(groot, 'defaultAxesFontSize',     15);
                set(groot, 'defaultLineLineWidth',     2);
                set(groot, 'defaultAxesLineWidth',     2);
                set(groot, 'defaultAxesBox',          'on');
                set(groot, 'defaultFigureUnits',      'centimeters');
                set(groot, 'defaultFigurePosition',  [2 2 14.8 21.0]);
                set(groot, 'defaultFigurePaperUnits', 'centimeters');
                set(groot, 'defaultFigurePaperType', 'a5');
                set(groot, 'defaultFigurePaperOrientation',  'portrait');
                set(groot, 'defaultFigurePaperPositionMode', 'auto');

            case {'a4', 'a4-landscape'}
                set(groot, 'defaultTextFontSize',     16);
                set(groot, 'defaultAxesFontSize',     16);
                set(groot, 'defaultLineLineWidth',     2);
                set(groot, 'defaultAxesLineWidth',     2);
                set(groot, 'defaultAxesBox',          'on');
                set(groot, 'defaultFigureUnits',      'centimeters');
                set(groot, 'defaultFigurePosition',  [2 2 29.7 21.0]);
                set(groot, 'defaultFigurePaperUnits', 'centimeters');
                set(groot, 'defaultFigurePaperType', 'a4');
                set(groot, 'defaultFigurePaperOrientation',  'landscape');
                set(groot, 'defaultFigurePaperPositionMode', 'auto');

            case {'a4-portrait'}
                set(groot, 'defaultTextFontSize',     16);
                set(groot, 'defaultAxesFontSize',     16);
                set(groot, 'defaultLineLineWidth',     2);
                set(groot, 'defaultAxesLineWidth',     2);
                set(groot, 'defaultAxesBox',          'on');
                set(groot, 'defaultFigureUnits',      'centimeters');
                set(groot, 'defaultFigurePosition',  [2 2 21.0 29.7]);
                set(groot, 'defaultFigurePaperUnits', 'centimeters');
                set(groot, 'defaultFigurePaperType', 'a4');
                set(groot, 'defaultFigurePaperOrientation',  'portrait');
                set(groot, 'defaultFigurePaperPositionMode', 'auto');

            case {'a3', 'a3-landscape'}
                set(groot, 'defaultTextFontSize',     17);
                set(groot, 'defaultAxesFontSize',     17);
                set(groot, 'defaultLineLineWidth',     2);
                set(groot, 'defaultAxesLineWidth',     2);
                set(groot, 'defaultAxesBox',          'on');
                set(groot, 'defaultFigureUnits',      'centimeters');
                set(groot, 'defaultFigurePosition',  [2 2 42.0 29.7]);
                set(groot, 'defaultFigurePaperUnits', 'centimeters');
                set(groot, 'defaultFigurePaperType', 'a3');
                set(groot, 'defaultFigurePaperOrientation',  'landscape');
                set(groot, 'defaultFigurePaperPositionMode', 'auto');

            case {'a3-portrait'}
                set(groot, 'defaultTextFontSize',     17);
                set(groot, 'defaultAxesFontSize',     17);
                set(groot, 'defaultLineLineWidth',     2);
                set(groot, 'defaultAxesLineWidth',     2);
                set(groot, 'defaultAxesBox',          'on');
                set(groot, 'defaultFigureUnits',      'centimeters');
                set(groot, 'defaultFigurePosition',  [2 2 29.7 42.0]);
                set(groot, 'defaultFigurePaperUnits', 'centimeters');
                set(groot, 'defaultFigurePaperType', 'a3');
                set(groot, 'defaultFigurePaperOrientation',  'portrait');
                set(groot, 'defaultFigurePaperPositionMode', 'auto');

            %TODO: define more themes...
            otherwise
                error(['SAK:' mfilename ':UnknownTheme'], ...
                      'The theme you specified is not recognised: "%s".', ...
                      fprintf(['{' repmat('''%s'',', 1, (numel(theme)-1)) '''%s''}'], theme{:}));
        end %switch lower(theme{tk})
    end % for tk = 1:numel(theme)

end % function set_default_groot()
