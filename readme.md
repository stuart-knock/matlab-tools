# A Collection of Generally Useful Matlab Functions

## Making these Functions Always Accessible

Add to or create a `startup.m` file and put it somewhere in Matlab's path, so
it'll be read when you launch Matlab. Under Linux, `~/Documents/MATLAB/` is a
good place. See [`startup`](https://www.mathworks.com/help/matlab/ref/startup.html)
and [`userpath`](https://www.mathworks.com/help/matlab/ref/userpath.html).

Eg. `startup.m`, assuming repo was cloned to `~/Github/`:

```matlab
%% Add directories to path at startup.
%matlab-tools and all subpaths.
addpath(genpath('~/GitHub/matlab-tools'), '-begin');

```

## Functions

### [cell2md](https://github.com/stuart-knock/matlab-tools/blob/master/cell2md.m)
Converts a cell array of char arrays into a MarkDown table.


### [alias_method](https://github.com/stuart-knock/matlab-tools/blob/master/alias_method.m)
Generates random samples from a discrete probability distribution using the
[alias-method](https://en.wikipedia.org/wiki/Alias_method).


### [open_figures](https://github.com/stuart-knock/matlab-tools/blob/master/open_figures.m)
Identifies open figures from handles in graphics object array.


### [save_figures](https://github.com/stuart-knock/matlab-tools/blob/master/save_figures.m)
Saves figures in a range of formats.


### [set_default_groot](https://github.com/stuart-knock/matlab-tools/blob/master/set_default_groot.m)
Sets a default graphics theme based on predefined sets of default properties.


### [sem](https://github.com/stuart-knock/matlab-tools/blob/master/sem.m)
Calculates the standard error in the mean, across dim 1 if not vector.


### [standardise_range](https://github.com/stuart-knock/matlab-tools/blob/master/standardise_range.m)
Rescales data to a specified range.


### `colourmaps` contains a small collection function for generating colormaps


#### [bluered](https://github.com/stuart-knock/matlab-tools/blob/master/colourmaps/bluered.m)
Diverging, blue to red.

#### [blues](https://github.com/stuart-knock/matlab-tools/blob/master/colourmaps/blues.m)
Sequential, shades of blue.

#### [yellowgreenblue](https://github.com/stuart-knock/matlab-tools/blob/master/colourmaps/yellowgreenblue.m)
Yellow through green to blue.
