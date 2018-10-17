%% Startup script for use with the Toolbox Toolbox.
%
% Here is a sample startup.m for works with the ToolboxToolbox.  You
% should copy this file to your system outside of the ToolboxToolbox
% folder.  You should rename this file to "startup.m".  You should edit
% Your startup.m with the correct toolboxToolboxDir, and any Matlab
% preferences you wish to change for your local machine.
%
% This sample is focused on the ToolboxToolbox.  You can include additional
% startup actions, if you wish.
%
% 2016-2017 benjamin.heasly@gmail.com

%% Where is ToolboxToolbox installed?

% a reasonable default, or pick your own
pathString = userpath();
if isempty(pathString)
    % userpath() was not set, try to choose a "home" folder
    if ispc()
        userFolder = fullfile(getenv('HOMEDRIVE'), getenv('HOMEPATH'));
    else
        userFolder = getenv('HOME');
    end
else
    % take the first folder on the userpath
    firstSeparator = find(pathString == pathsep(), 1, 'first');
    if isempty(firstSeparator)
        userFolder = pathString;
    else
        userFolder = pathString(1:firstSeparator-1);
    end
end
toolboxToolboxDir = fullfile(userFolder, 'ToolboxToolbox');


%% Set up the path.
originalDir = pwd();

try
    apiDir = fullfile(toolboxToolboxDir, 'api');
    cd(apiDir);
    tbResetMatlabPath('reset', 'full');
catch err
    warning('Error setting ToolboxToolbox path during startup: %s', err.message);
end

cd(originalDir);


%% Put /usr/local/bin on path so we can see things installed by Homebrew.
if ismac()
    setenv('PATH', ['/usr/local/bin:' getenv('PATH')]);
end


%% Matlab preferences that control ToolboxToolbox.

% clear old preferences, so we get a predictable starting place.
if (ispref('ToolboxToolbox'))
    rmpref('ToolboxToolbox');
end

% choose custom preferences below, or leave commented to accept defaults

% % default location for JSON configuration
% configPath = fullfile(tbUserFolder(), 'toolbox_config.json');
% setpref('ToolboxToolbox', 'configPath', configPath);

% % default folder to contain regular the toolboxes
% toolboxRoot = fullfile(tbUserFolder(), 'toolboxes');
% setpref('ToolboxToolbox', 'toolboxRoot', toolboxRoot);

% % default folder to contain shared, pre-installed toolboxes
% toolboxCommonRoot = '/srv/toolboxes';
% setpref('ToolboxToolbox', 'toolboxCommonRoot', toolboxCommonRoot);

% % default folder to contain non-toolbox projects
% projectRoot = fullfile(tbUserFolder(), 'projects');
% setpref('ToolboxToolbox', 'projectRoot', projectRoot);

% % default folder for hooks that set up local config for each toolbox
% localHookFolder = fullfile(tbUserFolder(), 'localHookFolder');
% setpref('ToolboxToolbox', 'localHookFolder', localHookFolder);

% % location of ToolboxHub or other toolbox registry
% registry = tbDefaultRegistry();
% setpref('ToolboxToolbox', 'registry', registry);

% system command used to check whether the Internet is reachable
%   this helps avoid long timeouts, when Internet isn't reachable
%   many commands would work fine
%   some suggestions:
%
% good default for Linux and OS X
% checkInternetCommand = 'ping -c 1 www.google.com';
%
% good default for Windows
% checkInternetCommand = 'ping -n 1 www.google.com';
%
% alternatives in case ping is blocked by firewall, etc.
% checkInternetCommand = 'curl www.google.com';
% checkInternetCommand = 'wget www.google.com';
%
% no-op to assume Internet is always reachable
% checkInternetCommand = '';
%
% setpref('ToolboxToolbox', 'checkInternetCommand', checkInternetCommand);

