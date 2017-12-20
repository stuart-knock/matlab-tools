%% Sets a default graphics theme based on predefined sets of default properties.
%
%  When setting a theme, a struct is returned containing a field for each groot
%  default value as it was prior to the call to this function.
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
        error(['BLN:' mfilename ':BadArgs'], 'You must specify a theme.')
    end

    if ischar(theme) && nargout < 1
        error(['BLN:' mfilename ':NoPreStateAssignment'], ...
              'You must capture the pre-call state to be able to undo the changes...');
    end

    precall_default_groot = get(groot, 'default');

    %% Set the default groot values based on struct with fields.
    if isstruct(theme)
        % Remove all current default groot values.
        default_fields = fieldnames(precall_default_groot);
        for index = 1:length(default_fields)
            set(groot, default_fields{index}, 'remove');
        end

        % Set default groot values based on input struct.
        default_fields = fieldnames(theme);
        for index = 1:length(default_fields)
            this_default = default_fields{index};
            set(groot, this_default, theme.(this_default));
        end
        return
    end

    %% Apply the default groot values for the requested theme.
    switch lower(theme)
        case 'dark'
            %% Set a dark colour theme.
            set(groot, 'defaultAxesColor',   [ 25,  25,  25] ./ 255);
            set(groot, 'defaultAxesYColor',  [255, 255, 255] ./ 255);
            set(groot, 'defaultAxesXColor',  [255, 255, 255] ./ 255);
            set(groot, 'defaultFigureColor', [ 25,  25,  25] ./ 255);
            set(groot, 'defaultTextColor',   [255, 255, 255] ./ 255);
        %TODO: define more themes...
        otherwise
            error(['BLN:' mfilename ':UnknownTheme'], ...
                  'The theme you specified is not recognised: "%s".', theme);
    end

end % function set_default_groot()
