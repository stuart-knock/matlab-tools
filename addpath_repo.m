%% Adds paths under a repository, excluding repo database.
%
%  When using genpath() on a directory containing a git or svn repository
%  the resulting path string includes all the stuff under .git or .svn.
%  This function strips these directories, and everything under them, from
%  the path string before calling addpath().
%
% ARGUMENTS:
%    repo_path -- string specifying path to the repository.
%    repo_type -- string specifying the type of repository, ['git'|'svn'].
%                 Defaults to 'git'.
%                 NOTE: For SVN, assumes version >=1.7. That is, only a single
%                       top level .svn directory is handled.
%
% OUTPUT:
%    repo_path_nodb -- path names for the repository excluding the information
%                      directories, that is, .git or .svn and its contents.
%                      Only really useful for debugging.
%
% REQUIRES: None
%
% AUTHOR:
%     Stuart A. Knock (2018-06-15).
%
% USAGE:
%{
    addpath_repo('~/GitHub/matlab-tools');
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [repo_path_nodb] = addpath_repo(repo_path, repo_type)
    %% Basic checks of arg
    if nargin < 1 || isempty(repo_path)
        error(['SAK:', mfilename, ':BadArgs'], ...
              'The first arg "repo_path" MUST be provided.');
    elseif ~isfolder(repo_path)
        error(['SAK:', mfilename, ':BadArgs'], ...
              ['Provided repo_path is not a directory: "' repo_path '"']);
    end
    %% Default to git
    if nargin < 2 || isempty(repo_type)
        repo_type = 'git';
    elseif ~any(strcmpi(repo_type, {'git', '.git', 'svn', '.svn'}))
        error(['SAK:', mfilename, ':BadArgs'], ...
              ['Unrecognised repo_type: "' repo_type '"']);
    end

    %% Add the path/s
    % Generate path names including all directories and subdirectories.
    all_repo_paths = genpath(repo_path);

    % Identify those paths that are part of the .git or .svn directory
    git_paths = regexp(all_repo_paths, [repo_path '/.' repo_type '(/\w*)*:'], 'match');

    % Remove the .git/* or .svn/* paths
    repo_path_nodb = replace(all_repo_paths, git_paths, '');

    % Add the cleaned-up path names to the matlab path.
    addpath(repo_path_nodb, '-begin');

end %function addpath_repo()
