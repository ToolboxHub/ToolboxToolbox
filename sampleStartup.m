%% Startup script for use with the Toolbox Toolbox.
%
% Here is a sample startup.m for works with the ToolboxToolbox.  You
% should copy this file to your system outside of the ToolboxToolbox
% folder.  You should rename this file to "startup.m".  You should edit
% Your startup.m with the correct toolboxToolboxDir, and any Matlab
% preferences you wish to change for your local machine.
%
% 2016 benjamin.heasly@gmail.com

%% Where is the Toolbox Toolbox installed?
toolboxToolboxDir = '~/ToolboxToolbox';

%% Set up the path.
originalDir = pwd();

try
    apiDir = fullfile(toolboxToolboxDir, 'api');
    cd(apiDir);
    tbResetMatlabPath('reset', 'local', 'withSelf', true);
catch err
    warning('Error setting Toolbox Toolbox path during startup: %s', ...
        err.message);
end

cd(originalDir);

%% Put /usr/local/bin on path so we can things installed by Homebrew.
if ismac()
    setenv('PATH', ['/usr/local/bin:' getenv('PATH')]);
end

%% Matlab preferences that control ToolboxToolbox.

% uncomment any or all of these that you wish to change

% % default location for JSON configuration
% configPath = '~/toolbox_config.json';
% setpref('ToolboxToolbox', 'configPath', configPath);

% % default folder to contain regular the toolboxes
% toolboxRoot = '~/toolboxes';
% setpref('ToolboxToolbox', 'toolboxRoot', toolboxRoot);

% % default folder to contain shared, pre-installed toolboxes
% toolboxCommonRoot = '/srv/toolboxes';
% setpref('ToolboxToolbox', 'toolboxCommonRoot', toolboxCommonRoot);

% % default folder for hooks that set up local config for each toolbox
% localHookFolder = '~/localToolboxHooks';
% setpref('ToolboxToolbox', 'localHookFolder', localHookFolder);

% % location of ToolboxHub or other toolbox registry
% registry = tbDefaultRegistry();
% setpref('ToolboxToolbox', 'registry', registry);
