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
% This function uses ToolboxToolbox shared parameters and preferences.  See
% tbParsePrefs().
%
% tbDeployToolboxes(... 'doUpdate', doUpdate) specifies whether to
% update the registry if it already exists (true), or to leave an existing
% registry as-is (false).  The default is true, update the registry like
% any other toolbox.
%
% 2016 benjamin.heasly@gmail.com

[prefs, others] = tbParsePrefs(varargin{:});

parser = inputParser();
parser.addParameter('doUpdate', true, @islogical);
parser.parse(others);
doUpdate = parser.Results.doUpdate;

%% Force no update?
if ~doUpdate
    prefs.registry.update = 'never';
end

%% Obtain or update just like a toolbox.
results = tbFetchToolboxes(prefs.registry, prefs);

