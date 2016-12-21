function snapshot = tbDeploymentSnapshot(config, varargin)
% Make a new config based on the given config, plus explicit flavors.
%
% The idea is to take an existing toolbox configuration and create a new
% configuration that is "version-pinned" or "snapshot".  This is done by
% trying to detect the deployed version number for each toolbox record in
% the given configuration.  This will work best when the given
% configuration has already been deployed.  For example:
%   results = tbUse('sample-repo');
%   snapshot = tbDeploymentSnapshot(results);
%   tbWriteConfig(snapshot, 'conigPath', 'my-snapshot.json');
%
% snapshot = tbDeploymentSnapshot(config) attempts to detect the toolbox
% version for each toolbox record in the given config.  Returns a new,
% corresponding toolbox configuration in which the "flavor" field contains
% the detected version for each toolbox.
%
% 2016 benjamin.heasly@gmail.com

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
    strategy = tbChooseStrategy(record, varargin{:});
    
    if isempty(strategy)
        continue;
    end
    
    flavor = strategy.detectFlavor(record, varargin{:});
    pinnedRecord = tbToolboxRecord(record, ...
        'update', 'never', ...
        'flavor', flavor);
    snapshotCell{tt} = pinnedRecord;
end


%% Gather system-wide version info.
systemInfo.matlab_ver = evalc('ver');
systemInfo.matlab_version = version();
systemInfo.java = version('-java');
systemInfo.computer = computer();
systemInfo.toolboxRegistry = detectRegistryFlavor(varargin{:});
systemInfo.toolboxToolbox = detectSelfFlavor(varargin{:});

% store in a bogus toolbox record, to be ignored by other functions
systemRecord = tbToolboxRecord( ...
    'importance', 'optional', ...
    'type', 'system info');
systemRecord.flavor = systemInfo;


%% Results as struct array.
snapshot = [systemRecord snapshotCell{:}];


%% Try to detect the toolbox registry version.
function registryFlavor = detectRegistryFlavor(varargin)
registry = tbFetchRegistry(varargin{:}, 'doUpdate', false);
registryFlavor = registry.strategy.detectFlavor(registry, varargin{:});


%% Try to detect the ToolboxToolbox flavor, assuming it's with Git.
function selfFlavor = detectSelfFlavor(varargin)
self = tbToolboxRecord( ...
    'toolboxRoot', fileparts(tbLocateSelf()), ...
    'name', 'ToolboxToolbox', ...
    'type', 'git');
strategy = TbGitStrategy(varargin{:});
selfFlavor = strategy.detectFlavor(self, varargin{:});
