%%
%
%  NOTE: Saved figure size for all non '.fig' formats is based on PaperSize.
%
% ARGUMENTS:
%    figure_handle -- .
%    save_formats -- .
%    fig_basename -- .
%    output_path -- .
%     -- .
%     -- .
%
% OUTPUT:
%     -- .
%
% REQUIRES:
%
% AUTHOR:
%     Stuart A. Knock (2018-06-02).
%
% USAGE:
%{
    figure_handle = figure;
    scatter(rand(16, 1), rand(16, 1))
    save_formats = {'eps', 'tiff', 'fig'}; %
    output_path = pwd;
    save_figure(figure_handle, save_formats, 'my_rand_figure', output_path);
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function save_figure(figure_handle, save_formats, fig_basename, output_path)
    if nargin < 1 || isempty(figure_handle)
        error(['SAK:' mfilename ':NoParticipants'], 'You must specify the figure_handle.');
    end
    if nargin < 2 || isempty(save_formats)
        save_formats = {'fig'}; %Default to matlab fig format.
    end
    if nargin < 3 || isempty(fig_basename)
        fig_basename = ['figure_' figure_handle.Number]; %Default to matlab fig format.
        if ~isempty(figure_handle.Name)
            fig_basename = [fig_basename '_' matlab.lang.makeValidName(figure_handle.Name)];
        end
    end
    if nargin < 4 || isempty(output_path)
        output_path = pwd; %Default to current working directory.
    elseif ~exist(output_path, 'dir')
        % Directory does not exist, but I'd rather not create it, so:
        error(['SAK:' mfilename ':BadPath'], ...
              'Output path does not exist. Create the directory: "%s".', output_path);
    end

    %% Save the figure in any requested formats.
    if ~isempty(save_formats)
        this_paper_size = figure_handle.PaperSize;
        for k = 1:numel(save_formats)
            full_path_figure = [output_path filesep fig_basename '.' save_formats{k}];
            disp(['Saving figure as: ' full_path_figure]);
            switch lower(save_formats{k})
                case {'pdf'}
                    print(figure_handle, full_path_figure, ['-d' save_formats{k}], '-fillpage');
                case {'svg'}
                    print(figure_handle, full_path_figure, ['-d' save_formats{k}]);
                case {'eps'}
                    print(figure_handle, full_path_figure, ['-d' save_formats{k} 'c']);
                case {'jpeg', 'tiff'}
                    if strcmp(figure_handle.PaperOrientation, 'portrait');
                        figure_handle.PaperOrientation = 'landscape';
                    else
                        figure_handle.PaperOrientation = 'portrait';
                    end
                    print(figure_handle, full_path_figure, ['-d' save_formats{k}]);
                    if strcmp(figure_handle.PaperOrientation, 'portrait');
                        figure_handle.PaperOrientation = 'landscape';
                    else
                        figure_handle.PaperOrientation = 'portrait';
                    end
                case {'fig'}
                    savefig(figure_handle, full_path_figure);
                otherwise
                    warning(['SAK:' mfilename ':UnrecognisedFormat'], ...
                            'Unrecognised save format: "%s".',        ...
                            save_formats{k})
            end % switch lower(save_formats{k})
        end % for k = 1:numel(save_formats)
    end % if ~isempty(save_formats)

end %function save_figure()
