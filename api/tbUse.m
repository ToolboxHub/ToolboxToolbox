function results = tbUse(registered, varargin)
% Deploy registered toolboxes by name.
%
% The goal here is to make it a one-liner to fetch toolboxes that are
% registerd on ToolboxHub and add them to the Matlab path.  This should
% automate several steps that we usually do by hand, which is good for
% consistency and convenience.
%
% results = tbUse('foo') fetches one toolbox named 'foo' from ToolboxHub
% and adds it to the Matlab path.
%
% results = tbUse({'foo', 'bar', ...}) fetches toolboxes named
% 'foo', 'bar', etc. from ToolboxHub and adds them to the matlab path.
%
% tbUse(... 'toolboxRoot', toolboxRoot) specifies the
% toolboxRoot folder to set the path for.  The default location is
% getpref('ToolboxToolbox', 'toolboxRoot'), or '~/toolboxes'.
%
% tbUse(... 'reset', reset) specifies which parts of the
% Matlab path to clear out before processing the given configuration.  The
% default is 'none', don't reset the path at all.  See tbResetMatlabPath().
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
parser.addRequired('registered', @(r) ischar(r) || iscellstr(r));
parser.addParameter('toolboxRoot', tbGetPref('toolboxRoot', '~/toolboxes'), @ischar);
parser.addParameter('toolboxCommonRoot', tbGetPref('toolboxCommonRoot', '/srv/toolboxes'), @ischar);
parser.addParameter('reset', 'none', @ischar);
parser.addParameter('localHookFolder', tbGetPref('localHookFolder', '~/localToolboxHooks'), @ischar);
parser.addParameter('registry', tbGetPref('registry', tbDefaultRegistry()), @(c) isempty(c) || isstruct(c));
parser.parse(registered, varargin{:});
registered = parser.Results.registered;
toolboxRoot = tbHomePathToAbsolute(parser.Results.toolboxRoot);
toolboxCommonRoot = tbHomePathToAbsolute(parser.Results.toolboxCommonRoot);
reset = parser.Results.reset;
localHookFolder = parser.Results.localHookFolder;
registry = parser.Results.registry;

% convert convenient string form to general list form
if ischar(registered)
    registered = {registered};
end

results = tbDeployToolboxes( ...
    'registered', registered, ...
    'toolboxRoot', toolboxRoot, ...
    'toolboxCommonRoot', toolboxCommonRoot, ...
    'reset', reset, ...
    'localHookFolder', localHookFolder, ...
    'registry', registry);
