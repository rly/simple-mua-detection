% run this function from the project root directory to set up the PATH
function config()

addpath(fullfile(pwd));
addpath(genpath(fullfile(pwd, 'helper')));
addpath(genpath(fullfile(pwd, 'util')));
addpath(genpath(fullfile(pwd, 'matlab_sdk')));

fprintf('Path variable is now set.\n');

