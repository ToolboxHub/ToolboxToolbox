function results = tbFetchRegistry(varargin)
% Obtain or update a registry of shared toolbox configurations.
%
% The goal here is to make it a one-liner to obtain or update a registry of
% shared toolbox configuration JSON files.  These JSON files can then be
% referred to by other configurations that use the "include" strategy.
%
% results = tbFetchRegistry() fetches or updates the default registry,
% which is the public registry at Toolbox Hub.
%
% tbFetchRegistry( ... 'registry', registry) specify an explicit toolbox
% record which indicates where and how to access the registry.  The default
% is getpref('ToolboxToolbox', 'registry'), or the public registry at
% Toolbox Hub.
%
% tbDeployToolboxes(... 'toolboxRoot', toolboxRoot) specifies the
% toolboxRoot folder where the registry should be saved.  The default
% location is getpref('ToolboxToolbox', 'toolboxRoot'), or 'toolboxes' in
% the userpath() folder.
%
% tbDeployToolboxes(... 'doUpdate', doUpdate) specifies whether to
% update the registry if it already exists (true), or to leave an existing
% registry as-is (false).  The default is true, update the registry like
% any other toolbox.
%
% 2016 benjamin.heasly@gmail.com


parser = inputParser();
parser.addParameter('registry', tbGetPref('registry', tbDefaultRegistry()), @(c) isempty(c) || isstruct(c));
parser.addParameter('toolboxRoot', tbGetPref('toolboxRoot', fullfile(tbUserFolder(), 'toolboxes')), @ischar);
parser.addParameter('doUpdate', true, @islogical);
parser.parse(varargin{:});
registry = parser.Results.registry;
toolboxRoot = tbHomePathToAbsolute(parser.Results.toolboxRoot);
doUpdate = parser.Results.doUpdate;

%% Force no update?
if ~doUpdate
    registry.update = 'never';
end

%% Obtain or update just like a toolbox.
results = tbFetchToolboxes(registry, 'toolboxRoot', toolboxRoot);
