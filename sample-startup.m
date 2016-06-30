%% Startup script for use with the Toolbox Toolbox.
%
% Here is a sample startup.m for that works with the Toolbox Toolbox.  You
% should copy this file to your system outside of the Toolbox Toolbox.  You
% should rename this file to "startup.m".  You should edit line 13 with the
% path to where you installed the Toolbox Toolbox.
%
% Locate Toolbox Toolbx and add it to the Matlab path.  Clear the rest of
% the Matlab path!  No more Solera method (unless you're making Sherry).
%
% 2016 benjamin.heasly@gmail.com

%% Where is the Toolbox Toolbox installed?
toolboxToolboxDir = '~/toolbox-toolbox';

%% Set up the path.
originalDir = pwd();

try
    apiDir = fullfile(toolboxToolboxDir, 'api');
    cd(apiDir);
    tbResetMatlabPath('withBuiltIn', true, 'withSelf', true);
catch err
    warning('Error setting Toolbox Toolbox path during startup: %s', ...
        err.message);
end

cd(originalDir);
