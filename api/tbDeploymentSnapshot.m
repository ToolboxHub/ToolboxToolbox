function snapshot = tbDeploymentSnapshot(config, persistentPrefs, varargin)
% Make a new config based on the given config, plus explicit flavors.
%
% The idea is to take an existing toolbox configuration and create a new
% configuration that is "version-pinned" or "snapshot".  This is done by
% trying to detect the deployed version number for each toolbox record in
% the given configuration.  This will work best when the given
% configuration has already been deployed.  For example:
%   results = tbUse('sample-repo');
%   snapshot = tbDeploymentSnapshot(results);
%   tbWriteConfig(snapshot, 'configPath', 'my-snapshot.json');
%   tbDeployToFolder('~/my-folder', 'configPath', 'my-snapshot.json');
%
% snapshot = tbDeploymentSnapshot(config) attempts to detect the toolbox
% version for each toolbox record in the given config.  Returns a new,
% corresponding toolbox configuration in which the "flavor" field contains
% the detected version for each toolbox.
%
% This function uses ToolboxToolbox shared parameters and preferences.  See
% tbParsePrefs().
%
% 2016 benjamin.heasly@gmail.com

prefs = tbParsePrefs(persistentPrefs, varargin{:});

parser = inputParser();
parser.KeepUnmatched = true;
parser.PartialMatching = false;
parser.addRequired('config', @isstruct);
parser.parse(config);
config = parser.Results.config;


%% Gather version info for each toolbox.
nToolboxes = numel(config);
snapshotCell = cell(1, nToolboxes);
for tt = 1:nToolboxes
    record = config(tt);
    strategy = tbChooseStrategy(record, persistentPrefs, prefs);
    
    if isempty(strategy)
        continue;
    end
    
    flavor = strategy.detectFlavor(record);
    pinnedRecord = tbToolboxRecord(record, ...
        'update', 'never', ...
        'flavor', flavor);
    snapshotCell{tt} = pinnedRecord;
end


%% Gather system-wide version info, just for reference.
systemInfo.matlab_version = version();
systemInfo.matlab_ver = evalc('ver');
systemInfo.java = version('-java');
systemInfo.computer = computer();
systemInfo.toolboxRegistry = getRegistryInfo(prefs);
systemInfo.toolboxToolbox = getSelfInfo(persistentPrefs, prefs);

% store in an empty toolbox record, to be ignored during deployment
systemRecord = tbToolboxRecord( ...
    'importance', 'optional', ...
    'type', 'system info');
systemRecord.extra = systemInfo;


%% Results as struct array.
snapshot = [snapshotCell{:} systemRecord];


%% Try to detect the toolbox registry version.
function registryInfo = getRegistryInfo(prefs)
registry = tbFetchRegistry(prefs, 'doUpdate', false);
flavor = registry.strategy.detectFlavor(registry);
registryInfo = tbToolboxRecord(registry, 'flavor', flavor);


%% Try to detect the ToolboxToolbox flavor, assuming it's with Git.
function selfInfo = getSelfInfo(persistentPrefs, prefs)
self = tbToolboxRecord( ...
    'toolboxRoot', fileparts(tbLocateSelf()), ...
    'name', 'ToolboxToolbox', ...
    'type', 'git');
strategy = tbChooseStrategy(self, persistentPrefs, prefs);
flavor = strategy.detectFlavor(self);
url = strategy.detectOriginUrl(self);
selfInfo = tbToolboxRecord(self, 'flavor', flavor, 'url', url);

