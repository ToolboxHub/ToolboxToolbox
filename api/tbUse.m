function results = tbUse(registered, varargin)
% Deploy registered toolboxes by name.
%
% The goal here is to make it a one-liner to fetch toolboxes that are
% registerd on ToolboxHub and add them to the Matlab path.  This should
% automate several steps that we usually do by hand, which is good for
% consistency and convenience.
%
% results = tbUse({'foo', 'bar', ...}) fetches toolboxes named
% 'foo', 'bar', etc. from ToolboxHub and adds them to the matlab path.
%
% tbUse(... 'toolboxRoot', toolboxRoot) specifies the
% toolboxRoot folder to set the path for.  The default location is
% getpref('ToolboxToolbox', 'toolboxRoot'), or '~/toolboxes'.
%
% tbUse(... 'resetPath', resetPath) specifies whether to
% restore the default Matlab path before setting up the toolbox path.  The
% default is false, just add to the existing path.
%
% tbUse(... 'withInstalled', withInstalled) specifies whether
% to include installed matlab toolboxes.  This only has an effect when
% resetPath is true.  The default is true, include all installed
% toolboxes on the path.
%
% tbUse( ... 'registry', registry) specify an explicit toolbox
% record which indicates where and how to access a registry of shared
% toolbox configurations.  The default is getpref('ToolboxToolbox',
% 'registry'), or the public registry at Toolbox Hub.
%
% tbUse(... 'localHookFolder', localHookFolder) specifies the
% path to the folder that contains local hook scripts.  The default
% location is getpref('ToolboxToolbox', 'localHookFolder'), or
% '~/toolboxes/localHooks'.
%
% tbUse( ... 'toolboxCommonRoot', toolboxCommonRoot) specify
% where to look for shared toolboxes. The default location is
% getpref('ToolboxToolbox', 'toolboxCommonRoot'), or '/srv/toolboxes'.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addRequired('registered', @iscellstr);
parser.addParameter('toolboxRoot', tbGetPref('toolboxRoot', '~/toolboxes'), @ischar);
parser.addParameter('toolboxCommonRoot', tbGetPref('toolboxCommonRoot', '/srv/toolboxes'), @ischar);
parser.addParameter('resetPath', false, @islogical);
parser.addParameter('withInstalled', true, @islogical);
parser.addParameter('localHookFolder', tbGetPref('localHookFolder', '~/localToolboxHooks'), @ischar);
parser.addParameter('registry', tbGetPref('registry', tbDefaultRegistry()), @(c) isempty(c) || isstruct(c));
parser.parse(registered, varargin{:});
registered = parser.Results.registered;
toolboxRoot = tbHomePathToAbsolute(parser.Results.toolboxRoot);
toolboxCommonRoot = tbHomePathToAbsolute(parser.Results.toolboxCommonRoot);
resetPath = parser.Results.resetPath;
withInstalled = parser.Results.withInstalled;
localHookFolder = parser.Results.localHookFolder;
registry = parser.Results.registry;

results = tbDeployToolboxes( ...
    'registered', registered, ...
    'toolboxRoot', toolboxRoot, ...
    'toolboxCommonRoot', toolboxCommonRoot, ...
    'resetPath', resetPath, ...
    'withInstalled', withInstalled, ...
    'localHookFolder', localHookFolder, ...
    'registry', registry);
