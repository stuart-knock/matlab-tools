# A collection of generally useful Matlab functions

Add to or create a `startup.m` file and put it somewhere in Matlab's path, so
it'll be read when you launch Matlab. Under Linux, `~/Documents/MATLAB/` is a
good place.

Eg. `startup.m`, assuming repo was cloned to `~/Github/`:

```matlab
%% Add directories to path at startup.
%matlab-tools and all subpaths.
addpath(genpath('~/GitHub/matlab-tools'), '-begin');
```
