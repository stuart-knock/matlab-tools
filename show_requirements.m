%% Displays files and products used either directly or indirectly by a function.
%
% Directly means that a function makes a call itself, while indirectly includes
% recursive analysis of functions called by the specified function.
%
% The dependency analysis step uses matlab.codetools.requiredFilesAndProducts,
% while show_requirements() just formats the display.
%
% Note: Matlab's dependency analysis is incomplete, meaning that, in some cases
%       it can fail to identify all actual dependencies.
%
% ARGUMENTS:
%    func
%        Char-vector or cell-array of char-vectors indicating the function or
%        file to analyse.
%
%    fmt
%        Char-vector indicating what to display, default is a flat display of
%        only those functions and products used directly by func. All options,
%        and what they display are as follows:
%            'flat', 'flat-top-only': only files/products used directly by func.
%            'flat-all': all files/products used [in]directly by func.
%            'tree': shows tree for file dependencies to depth 2, shows flat
%                    view for all product dependencies.
%            'tree-all': shows tree for file dependencies for "all" direct and
%                        indirect dependencies ("all" is actually capped at
%                        depth == 8, to protect against excessively indirect
%                        code), shows flat view for all product dependencies.
%            'tree-N': where N is a number, shows tree for file dependencies to
%                      depth N, shows flat view for all product dependencies.
%
% OUTPUT:
%    None: file and product lists are printed to terminal. Use the built-in
%    function matlab.codetools.requiredFilesAndProducts() directly if you want
%    access to variables containing the identified dependencies.
%
% USAGE:
%
%    % Show only requirements called directly by the specified function.
%    show_requirements('show_requirements');
%
%    % A flat view of all requirements, those called directly and indirectly.
%    show_requirements('show_requirements', 'flat-all');
%
%    % A tree view of file requirements, to a depth of 2, that is functions
%    % called directly and functions that those functions call directly.
%    show_requirements('show_requirements', 'tree');
%
%    % A tree view of file requirements, to a depth of 4, that is functions
%    % called directly and functions that those functions repeated.
%    show_requirements('show_requirements', 'tree-4');
%
%
% AUTHOR:
%     Stuart A.Knock (2020-08-05).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function show_requirements(func, fmt)
    if nargin < 2 || isempty(fmt)
        fmt = 'flat-top-only'; %display results as a flat list.
    end

    if ismember(lower(fmt), {'flat', 'flat-top-only'})
        [files, products] = matlab.codetools.requiredFilesAndProducts(func, 'toponly');
        display_flat(files);
        display_flat(products);
    elseif strcmpi(fmt, 'flat-all')
        [files, products] = matlab.codetools.requiredFilesAndProducts(func);
        display_flat(files);
        display_flat(products);
    elseif contains(lower(fmt), 'tree')
        excessive_indirection_depth_protector = 8; %Maximum accepted depth.
        modifier = fmt(6:end);
        if isempty(modifier)
            depth = 2;
        elseif strcmp(modifier, 'all')
            depth = excessive_indirection_depth_protector;
        else
            depth = str2double(modifier);
        end
        display_tree_view(func, depth, 0);
        [~, products] = matlab.codetools.requiredFilesAndProducts(func);
        display_flat(products);
    end

end %function show_requirements()


%% Tree print the file dependencies as function call names.
function display_tree_view(f, depth, current_depth)
    if strcmp(f((end-1):end), '.m')
        func_name = func_name_from_path(f);
    else
        func_name = f;
    end
    fprintf([repmat('\t', [1, current_depth]) '%s()\n'], func_name)

    current_depth = current_depth + 1;
    if current_depth > depth
        return
    end

    required_files = matlab.codetools.requiredFilesAndProducts(f, 'toponly');
    called_funcs = cellfun(          ...
        @(x) func_name_from_path(x), ...
        required_files,              ...
        'UniformOutput', false       ...
    );
    required_files = required_files(~strcmp(func_name, called_funcs));

    for k = 1:numel(required_files)
        display_tree_view(required_files{k}, depth, current_depth);
    end
end %function tree_view_requirements()


%% Generate a function call name from a file path, including name-space.
function func_name = func_name_from_path(function_path)
    func_name = function_path(regexp(function_path, '\+.*.m')+1:end-2);
    func_name = regexprep(func_name, [filesep '\+'], '.');
    func_name = regexprep(func_name, '\+', '.');
    func_name = regexprep(func_name, filesep, '.');
    if isempty(func_name)
        % It is not name-spaced, so just get the file name.
        [~, func_name] = fileparts(function_path);
    end
    % func_name = func_name;
end %function func_name_from_path()


%% Pretty print the required files and products in flat lists
function display_flat(requirements)
    if iscell(requirements) % Assuming it is the required-files
        fprintf('\n%s\n', 'Required Files:')
        fprintf('    %s\n', requirements{:})
        fprintf('\n')
    elseif isstruct(requirements) % Assuming it is the required-products
        fprintf('\n%s\n', 'Required Products:')
        fprintf('    %s\n', requirements(:).Name)
        fprintf('\n')
    end
end %function display_flat()
