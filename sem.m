%% Calculates the standard error in the mean, across dim 1 if not vector..
%
%
% ARGUMENTS:
%    data -- if >= 2 dimensions, over columns.
%
% OUTPUT:
%    std_err_mean -- standard error in the mean..
%
% REQUIRES:
%    nanstd -- Standard deviation ignoring NaNs, part of statistics package.
%
% AUTHOR:
%     Stuart A. Knock (2018-06-13).
%
% USAGE:
%{
    
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [std_err_mean] = sem(data)

    std_err_mean = nanstd(data) ./ sqrt(sum(~isnan(data)));

end %function sem()
