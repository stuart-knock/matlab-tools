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
    if nargin < 1 || isempty(theme) || ~(isstruct(theme) || ischar(theme))
        error(['SAK:' mfilename ':BadArgs'], 'You must specify a theme.')
    end

    if ischar(theme) && ~ismember(theme, {'default', 'matlab'}) && nargout < 1
        error(['SAK:' mfilename ':NoPreStateAssignment'], ...
              'The pre-call state must be captured to enable undoing changes.');
    end

    % Capture the pre-call default groot state.
    precall_default_groot = get(groot, 'default');

    % Remove all current, user set, default groot values.
    precall_default_fields = fieldnames(precall_default_groot);
    for index = 1:length(precall_default_fields)
        set(groot, precall_default_fields{index}, 'remove');
    end

    %% Set the default groot values based on struct with fields.
    if isstruct(theme)
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

    %% Apply the default groot values for the requested theme.
    switch lower(theme)
        case {'default', 'matlab'}
            %% Reset to the default Matlab theme.
            return

        case 'dark'
            %% Set a dark theme.
            set(groot, 'defaultFigureColor',       [ 25,  25,  25] ./ 255);
            set(groot, 'defaultAxesColor',         [ 25,  25,  25] ./ 255);
            set(groot, 'defaultAxesYColor',        [255, 255, 255] ./ 255);
            set(groot, 'defaultAxesXColor',        [255, 255, 255] ./ 255);
            set(groot, 'defaultTextColor',         [255, 255, 255] ./ 255);
            set(groot, 'defaultTextFontSize',      16);
            set(groot, 'defaultAxesFontSize',      16);
            set(groot, 'defaultAxesLineWidth',      2);
            set(groot, 'defaultLineLineWidth',      2);
            set(groot, 'defaultAxesBox',           'on');
            set(groot, 'defaultFigurePaperUnits',  'centimeters');
            set(groot, 'defaultFigureUnits',       'centimeters');
            set(groot, 'defaultFigurePaperSize',   [10 18]);
            set(groot, 'defaultFigurePosition',    [2 2 20 12]);
            set(groot, 'defaultFigurePaperPositionMode', 'auto');
            set(groot, 'defaultFigurePaperOrientation',  'landscape');
            set(groot, 'defaultFigureInvertHardcopy', 'off');

        case {'grey', 'gray', 'winter'}
            %% Set a grey theme.
            set(groot, 'defaultFigureColor',      [ 64,  64,  64] ./ 255);
            set(groot, 'defaultAxesColor',        [ 64,  64,  64] ./ 255);
            set(groot, 'defaultAxesYColor',       [128, 128, 128] ./ 255);
            set(groot, 'defaultAxesXColor',       [128, 128, 128] ./ 255);
            set(groot, 'defaultTextColor',        [128, 128, 128] ./ 255);
            set(groot, 'defaultAxesGridColor',    [ 96,  96,  96] ./ 255);
            set(groot, 'DefaultFigureColormap',   'winter');
            set(groot, 'defaultTextFontSize',     16);
            set(groot, 'defaultAxesFontSize',     16);
            set(groot, 'defaultLineLineWidth',     2);
            set(groot, 'defaultAxesLineWidth',     2);
            set(groot, 'defaultAxesBox',          'off');
            set(groot, 'defaultFigurePaperUnits', 'centimeters');
            set(groot, 'defaultFigureUnits',      'centimeters');
            set(groot, 'defaultFigurePaperSize',  [10 18]);
            set(groot, 'defaultFigurePosition',   [2 2 20 12]);
            set(groot, 'defaultFigurePaperPositionMode', 'auto');
            set(groot, 'defaultFigurePaperOrientation',  'landscape');
            set(groot, 'defaultFigureInvertHardcopy', 'off');

        case 'paper'
            %% Set a paper theme.
            set(groot, 'defaultAxesColor',        [255, 255, 255] ./ 255);
            set(groot, 'defaultAxesYColor',       [  0,   0,   0] ./ 255);
            set(groot, 'defaultAxesXColor',       [  0,   0,   0] ./ 255);
            set(groot, 'defaultFigureColor',      [255, 255, 255] ./ 255);
            set(groot, 'defaultTextColor',        [  0,   0,   0] ./ 255);
            set(groot, 'defaultAxesGridColor',    [ 26,  26,  26] ./ 255);
            set(groot, 'defaultAxesGridAlpha',     1);
            set(groot, 'defaultTextFontSize',     16);
            set(groot, 'defaultAxesFontSize',     16);
            set(groot, 'defaultLineLineWidth',     2);
            set(groot, 'defaultAxesLineWidth',     2);
            set(groot, 'defaultAxesBox',          'on');
            set(groot, 'defaultFigurePaperUnits', 'centimeters');
            set(groot, 'defaultFigureUnits',      'centimeters');
            set(groot, 'defaultFigurePaperSize', [21 29.7]);
            set(groot, 'defaultFigurePaperType', 'a4');
            set(groot, 'defaultFigurePosition',  [2 2 20 12]);
            set(groot, 'defaultFigurePaperPositionMode', 'auto');
            set(groot, 'defaultFigurePaperOrientation',  'landscape');

        case 'rand'
            %% Set a random colour theme.
            set(groot, 'defaultAxesColor',     [rand, rand, rand]);
            set(groot, 'defaultAxesYColor',    [rand, rand, rand]);
            set(groot, 'defaultAxesXColor',    [rand, rand, rand]);
            set(groot, 'defaultFigureColor',   [rand, rand, rand]);
            set(groot, 'defaultTextColor',     [rand, rand, rand]);
            set(groot, 'defaultAxesGridColor', [rand, rand, rand]);

        %TODO: define more themes...
        otherwise
            error(['SAK:' mfilename ':UnknownTheme'], ...
                  'The theme you specified is not recognised: "%s".', theme);
    end %switch lower(theme)

end % function set_default_groot()
