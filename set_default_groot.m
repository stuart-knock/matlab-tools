%% Sets a default graphics theme based on predefined sets of default properties.
%
%  When setting a theme, an onCleanup object is returned. Deleting this object
%  will automatically reset groot default values as they were prior to the call
%  to this function. So, if run within a function, side effects are prevented as
%  the onCleanup object is automatically deleted on return from the function.
%
%  ARGUMENTS:
%    theme -- a char vector or a cell array of char vectors specifying one of
%             the predefined themes. Pre-defined themes have two components,
%             either or both of which can be specified. One component sets
%             colours, the other sizes:
%
%        Colour:
%            'dark' -- Almost black background; very light grey text and lines.
%            'light' -- White background; black text and lines.
%            'paper-grey' -- Grey-scale colormap; black text and lines; white background.
%            'grey' -- Dark grey background; light grey text and lines.
%            'grey-ygb' -- Same as 'grey'; with yellow-green-blue colormap.
%            'winter' -- Same as 'grey'; with winter colormap.
%            'winter-ocean' -- Same as 'grey'; with blues colormap.
%            'rand' -- sets random colours, because, why not.
%
%        Size/Scaling:
%            'small'  -- [16.18 10.0] cm, landscape.
%            'medium' -- [24.27 15.0] cm, landscape.
%            'large'  -- [32.36 20.0] cm, landscape.
%            'XL'     -- [48.54 30.0] cm, landscape.
%            'small-portrait'  -- [10.0 16.18] cm.
%            'medium-portrait' -- [15.0 24.27] cm.
%            'large-portrait'  -- [20.0 32.36] cm.
%            'XL-portrait'     -- [30.0 48.54] cm.
%            'small-square'  -- [10.0 10.0] cm.
%            'medium-square' -- [16.0 16.0] cm.
%            'large-square'  -- [22.0 22.0] cm.
%            'XL-square'     -- [32.0 32.0] cm.
%            'a5' -- [21.0 14.8] cm, landscape.
%            'a4' -- [29.7 21.0] cm, landscape.
%            'a3' -- [42.0 29.7] cm, landscape.
%            'a5-portrait' -- [14.8 21.0] cm.
%            'a4-portrait' -- [21.0 29.7] cm.
%            'a3-portrait' -- [29.7 42.0] cm.
%
%
%  OUTPUT:
%    pdg_sentinel -- an onCleanup object, that once deleted will reset default
%                    groot values to what they were before calling this function.
%                    You must capture this output.
%
%  AUTHOR:
%    Paula Sanz-Leon (2017-12-04).
%    Stuart A. Knock (2017-12-13).
%
%  USAGE:
%{
    %% Set a dark theme
    [pdg_sentinel] = set_default_groot({'dark', 'medium'});

    %plot things using this theme

    %% When used within a function, the pdg_sentinel will be deleted when it
    % goes out of scope, such as retuning from the function, automatically
    % running the clean-up. However, within a script or when called at a
    % command prompt, pdg_sentinel must be deleted manually to reset to the
    % default groot values from before the call.
    clear pdg_sentinel

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pdg_sentinel] = set_default_groot(theme)
    % A theme must be provided, allows struct for internal clean-up call purposes only.
    if nargin < 1 || isempty(theme) || ~(isstruct(theme) || ischar(theme) || iscell(theme)) %
        error(['SAK:' mfilename ':BadArgs'], 'You must specify a theme.')
    end

    % If setting a new theme, onCleanup object (pdg_sentinel) must be captured.
    if ~isstruct(theme) && nargout < 1
        error(['SAK:' mfilename ':UncapturedOutput'], ...
              ['You must capture the pdg_sentinel return arg. That is:\n', ...
               '    [pdg_sentinel] = set_default_groot(<theme>);'])
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

    % Define a clean-up function
    pdg_sentinel = onCleanup(@() set_default_groot(precall_default_groot));

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
                set(groot, 'defaultAxesXColor',    [191.25,  191.25,  191.25]  ./ 255);
                set(groot, 'defaultAxesYColor',    [191.25,  191.25,  191.25]  ./ 255);
                set(groot, 'defaultAxesZColor',    [191.25,  191.25,  191.25]  ./ 255);
                set(groot, 'defaultTextColor',     [191.25,  191.25,  191.25]  ./ 255);
                set(groot, 'defaultTextboxshapeColor',     [191.25, 191.25, 191.25] ./ 255);
                set(groot, 'defaultTextboxshapeEdgeColor', [191.25, 191.25, 191.25] ./ 255);
                set(groot, 'defaultAxesGridColor', [ 63.75,   63.75,   63.75]  ./ 255);
                set(groot, 'defaultAxesBox',       'on');
                set(groot, 'defaultFigureInvertHardcopy',    'off');

            case 'light'
                %% Set a light theme.
                set(groot, 'defaultAxesColor',     [255, 255, 255] ./ 255);
                set(groot, 'defaultAxesXColor',    [  0,   0,   0] ./ 255);
                set(groot, 'defaultAxesYColor',    [  0,   0,   0] ./ 255);
                set(groot, 'defaultAxesZColor',    [  0,   0,   0] ./ 255);
                set(groot, 'defaultFigureColor',   [255, 255, 255] ./ 255);
                set(groot, 'defaultTextColor',     [  0,   0,   0] ./ 255);
                set(groot, 'defaultTextboxshapeColor',     [0, 0, 0] ./ 255);
                set(groot, 'defaultTextboxshapeEdgeColor', [0, 0, 0] ./ 255);
                set(groot, 'defaultAxesGridColor', [ 26,  26,  26] ./ 255);
                set(groot, 'defaultAxesGridAlpha', 1);
                set(groot, 'defaultAxesBox',       'on');

            case {'paper-grey', 'paper-gray'}
                %% Set a light theme with default grey scale colourmap.
                set(groot, 'defaultAxesColor',     [255, 255, 255] ./ 255);
                set(groot, 'defaultAxesXColor',    [  0,   0,   0] ./ 255);
                set(groot, 'defaultAxesYColor',    [  0,   0,   0] ./ 255);
                set(groot, 'defaultAxesZColor',    [  0,   0,   0] ./ 255);
                set(groot, 'defaultFigureColor',   [255, 255, 255] ./ 255);
                set(groot, 'defaultTextColor',     [  0,   0,   0] ./ 255);
                set(groot, 'defaultTextboxshapeColor',     [0, 0, 0] ./ 255);
                set(groot, 'defaultTextboxshapeEdgeColor', [0, 0, 0] ./ 255);
                set(groot, 'defaultAxesGridColor', [ 26,  26,  26] ./ 255);
                set(groot, 'DefaultFigureColormap', gray);
                set(groot, 'DefaultAxesColorOrder', gray(7));
                set(groot, 'defaultAxesGridAlpha', 1);
                set(groot, 'defaultAxesBox',       'on');

            case {'grey', 'gray'}
                %% Set a grey theme.
                set(groot, 'defaultFigureColor',    [ 64,  64,  64] ./ 255);
                set(groot, 'defaultAxesColor',      [ 64,  64,  64] ./ 255);
                set(groot, 'defaultAxesXColor',     [128, 128, 128] ./ 255);
                set(groot, 'defaultAxesYColor',     [128, 128, 128] ./ 255);
                set(groot, 'defaultAxesZColor',     [128, 128, 128] ./ 255);
                set(groot, 'defaultTextColor',      [128, 128, 128] ./ 255);
                set(groot, 'defaultTextboxshapeColor',     [128, 128, 128] ./ 255);
                set(groot, 'defaultTextboxshapeEdgeColor', [128, 128, 128] ./ 255);
                set(groot, 'defaultAxesGridColor',  [ 96,  96,  96] ./ 255);
                set(groot, 'defaultAxesBox',        'off');
                set(groot, 'defaultFigureInvertHardcopy',    'off');

            case {'grey-ygb', 'grey-yellow-green-blue'}
                %% Set a winter (greys and winter colormap) theme.
                set(groot, 'defaultFigureColor',           [ 64,  64,  64] ./ 255);
                set(groot, 'defaultAxesColor',             [ 64,  64,  64] ./ 255);
                set(groot, 'defaultAxesXColor',            [128, 128, 128] ./ 255);
                set(groot, 'defaultAxesYColor',            [128, 128, 128] ./ 255);
                set(groot, 'defaultAxesZColor',            [128, 128, 128] ./ 255);
                set(groot, 'defaultTextColor',             [128, 128, 128] ./ 255);
                set(groot, 'defaultTextboxshapeColor',     [128, 128, 128] ./ 255);
                set(groot, 'defaultTextboxshapeEdgeColor', [128, 128, 128] ./ 255);
                set(groot, 'defaultAxesGridColor',         [ 96,  96,  96] ./ 255);
                set(groot, 'DefaultFigureColormap', yellowgreenblue([], 'rev'));
                set(groot, 'DefaultAxesColorOrder', yellowgreenblue( 7, 'rev'));
                set(groot, 'defaultAxesBox',        'off');
                set(groot, 'defaultFigureInvertHardcopy',    'off');

            case {'winter'}
                %% Set a winter (greys and winter colormap) theme.
                set(groot, 'defaultFigureColor',           [ 64,  64,  64] ./ 255);
                set(groot, 'defaultAxesColor',             [ 64,  64,  64] ./ 255);
                set(groot, 'defaultAxesXColor',            [128, 128, 128] ./ 255);
                set(groot, 'defaultAxesYColor',            [128, 128, 128] ./ 255);
                set(groot, 'defaultAxesZColor',            [128, 128, 128] ./ 255);
                set(groot, 'defaultTextColor',             [128, 128, 128] ./ 255);
                set(groot, 'defaultTextboxshapeColor',     [128, 128, 128] ./ 255);
                set(groot, 'defaultTextboxshapeEdgeColor', [128, 128, 128] ./ 255);
                set(groot, 'defaultAxesGridColor',         [ 96,  96,  96] ./ 255);
                set(groot, 'DefaultFigureColormap', winter);
                set(groot, 'DefaultAxesColorOrder', winter(7));
                set(groot, 'defaultAxesBox',        'off');
                set(groot, 'defaultFigureInvertHardcopy',    'off');

            case {'winter-ocean'}
                %% Set a winter-ocean (greys and blues colourmap) theme.
                set(groot, 'defaultFigureColor',    [ 64,  64,  64] ./ 255);
                set(groot, 'defaultAxesColor',      [ 64,  64,  64] ./ 255);
                set(groot, 'defaultAxesXColor',     [128, 128, 128] ./ 255);
                set(groot, 'defaultAxesYColor',     [128, 128, 128] ./ 255);
                set(groot, 'defaultAxesZColor',     [128, 128, 128] ./ 255);
                set(groot, 'defaultTextColor',      [128, 128, 128] ./ 255);
                set(groot, 'defaultTextboxshapeColor',     [128, 128, 128] ./ 255);
                set(groot, 'defaultTextboxshapeEdgeColor', [128, 128, 128] ./ 255);
                set(groot, 'defaultAxesGridColor',  [ 96,  96,  96] ./ 255);
                set(groot, 'DefaultFigureColormap', blues);
                set(groot, 'DefaultAxesColorOrder', blues(7));
                set(groot, 'defaultAxesBox',        'off');
                set(groot, 'defaultFigureInvertHardcopy',    'off');

            case 'rand'
                %% Set a random colour theme.
                set(groot, 'defaultAxesColor',     [rand, rand, rand]);
                set(groot, 'defaultAxesXColor',    [rand, rand, rand]);
                set(groot, 'defaultAxesYColor',    [rand, rand, rand]);
                set(groot, 'defaultAxesZColor',    [rand, rand, rand]);
                set(groot, 'defaultFigureColor',   [rand, rand, rand]);
                set(groot, 'defaultTextColor',     [rand, rand, rand]);
                set(groot, 'defaultTextboxshapeColor',     [rand, rand, rand] ./ 255);
                set(groot, 'defaultTextboxshapeEdgeColor', [rand, rand, rand] ./ 255);
                set(groot, 'defaultAxesGridColor', [rand, rand, rand]);
                set(groot, 'defaultFigureInvertHardcopy',    'off');

            %Scaling/sizing themes
            case {'small', 'small-landscape'}
                set(groot, 'defaultTextFontSize',      14);
                set(groot, 'defaultAxesFontSize',      14);
                set(groot, 'defaultTextboxshapeFontSize', 13);
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
                set(groot, 'defaultTextboxshapeFontSize', 14);
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
                set(groot, 'defaultTextboxshapeFontSize', 15);
                set(groot, 'defaultAxesLineWidth',     2);
                set(groot, 'defaultLineLineWidth',     2);
                set(groot, 'defaultFigureUnits',      'centimeters');
                set(groot, 'defaultFigurePosition',   [2 2 32.36 20.0]);
                set(groot, 'defaultFigurePaperUnits', 'centimeters');
                set(groot, 'defaultFigurePaperSize',  [32.36 20.0]);
                set(groot, 'defaultFigurePaperType',   '<custom>');
                set(groot, 'defaultFigurePaperOrientation',  'landscape');
                set(groot, 'defaultFigurePaperPositionMode', 'auto');

            case {'xl', 'xl-landscape', 'extra-large', 'extra-large-landscape'}
                set(groot, 'defaultTextFontSize',     16);
                set(groot, 'defaultAxesFontSize',     16);
                set(groot, 'defaultTextboxshapeFontSize', 15);
                set(groot, 'defaultAxesLineWidth',     2);
                set(groot, 'defaultLineLineWidth',     2);
                set(groot, 'defaultFigureUnits',      'centimeters');
                set(groot, 'defaultFigurePosition',   [2 2 48.54 30.0]);
                set(groot, 'defaultFigurePaperUnits', 'centimeters');
                set(groot, 'defaultFigurePaperSize',  [48.54 30.0]);
                set(groot, 'defaultFigurePaperType',   '<custom>');
                set(groot, 'defaultFigurePaperOrientation',  'landscape');
                set(groot, 'defaultFigurePaperPositionMode', 'auto');

            case {'small-protrait'}
                set(groot, 'defaultTextFontSize',      14);
                set(groot, 'defaultAxesFontSize',      14);
                set(groot, 'defaultTextboxshapeFontSize', 13);
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
                set(groot, 'defaultTextboxshapeFontSize', 14);
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
                set(groot, 'defaultTextboxshapeFontSize', 15);
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
                set(groot, 'defaultTextboxshapeFontSize', 13);
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
                set(groot, 'defaultTextboxshapeFontSize', 14);
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
                set(groot, 'defaultTextboxshapeFontSize', 15);
                set(groot, 'defaultAxesLineWidth',      2);
                set(groot, 'defaultLineLineWidth',      2);
                set(groot, 'defaultFigureUnits',       'centimeters');
                set(groot, 'defaultFigurePosition',    [2 2 22 22]);
                set(groot, 'defaultFigurePaperUnits',  'centimeters');
                set(groot, 'defaultFigurePaperSize',   [22 22]);
                set(groot, 'defaultFigurePaperType',   '<custom>');
                set(groot, 'defaultFigurePaperOrientation',  'portrait');
                set(groot, 'defaultFigurePaperPositionMode', 'auto');

            case {'xl-square', 'extra-large-square'}
                set(groot, 'defaultTextFontSize',      18);
                set(groot, 'defaultAxesFontSize',      18);
                set(groot, 'defaultTextboxshapeFontSize', 17);
                set(groot, 'defaultAxesLineWidth',      2);
                set(groot, 'defaultLineLineWidth',      2);
                set(groot, 'defaultFigureUnits',       'centimeters');
                set(groot, 'defaultFigurePosition',    [2 2 32 32]);
                set(groot, 'defaultFigurePaperUnits',  'centimeters');
                set(groot, 'defaultFigurePaperSize',   [32 32]);
                set(groot, 'defaultFigurePaperType',   '<custom>');
                set(groot, 'defaultFigurePaperOrientation',  'portrait');
                set(groot, 'defaultFigurePaperPositionMode', 'auto');

            case {'a5', 'a5-landscape'}
                set(groot, 'defaultTextFontSize',     15);
                set(groot, 'defaultAxesFontSize',     15);
                set(groot, 'defaultTextboxshapeFontSize', 14);
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
                set(groot, 'defaultTextboxshapeFontSize', 14);
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
                set(groot, 'defaultTextboxshapeFontSize', 15);
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
                set(groot, 'defaultTextboxshapeFontSize', 15);
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
                set(groot, 'defaultTextboxshapeFontSize', 16);
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
                set(groot, 'defaultTextboxshapeFontSize', 16);
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
                      sprintf(['{' repmat('''%s'',', 1, (numel(theme)-1)) '''%s''}'], theme{:}));
        end %switch lower(theme{tk})
    end % for tk = 1:numel(theme)

end % function set_default_groot()
