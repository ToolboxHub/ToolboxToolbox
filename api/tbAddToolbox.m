function results = tbAddToolbox(varargin)
% Add a toolbox to the toolbox configuration, fetch it, add it to the path.
%
% The goal here is to make it a one-liner to add a new toolbox to the
% working configuration.  So this is just a utility wrapper on other
% toolbox functions.
%
% results = tbAddToolbox( ... name, value) creates a new toolbox record
% based on the given name-value pairs and adds it to the toolbox
% configuration.  See tbToolboxRecord for recognized names.
%
% If a toolbox with the same 'name" already exists in the configuration, it
% will be replaced with the new one.
%
% tbAddToolbox( ... 'configPath', configPath) specify where to look for the
% toolbox config file.  The default location is '~/toolbox-config.json'.
%
% tbReadConfig( ... 'toolboxRoot', toolboxRoot) specify where to fetch
% toolboxes.  The default location is '~/toolboxes'.
%
% As an optimization for shares systems, toolboxes may be pre-deployed
% (probably by an admin) to a common toolbox root folder.  Toolboxes found
% here will be updated, instead adding new ones to the given toolboxRoot.
%
% tbFetchToolboxes( ... 'toolboxCommonRoot', toolboxCommonRoot) specify
% where to look for shared toolboxes.  The default location is
% '/srv/toolbox-toolbox/toolboxes'.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.KeepUnmatched = true;
parser.addParameter('configPath', '~/toolbox-config.json', @ischar);
parser.addParameter('toolboxRoot', '~/toolboxes', @ischar);
parser.addParameter('toolboxCommonRoot', '/srv/toolbox-toolbox/toolboxes', @ischar);
parser.parse(varargin{:});
configPath = tbHomePathToAbsolute(parser.Results.configPath);
toolboxRoot = tbHomePathToAbsolute(parser.Results.toolboxRoot);
toolboxCommonRoot = tbHomePathToAbsolute(parser.Results.toolboxCommonRoot);

%% Make a new toolbox record.
newRecord = tbToolboxRecord(varargin{:});

%% Deploy just the new toolbox.
results = tbDeployToolboxes( ...
    'config', newRecord, ...
    'toolboxRoot', toolboxRoot, ...
    'toolboxCommonRoot', toolboxCommonRoot, ...
    'restorePath', false);

if 0 ~= results.status
    error('AddToolbox:deployError', 'Could not deploy toolbox with name "%s": %s', ...
        results.name, results.message);
end

%% Add new toolbox to the existing config.
config = tbReadConfig('configPath', configPath);
if isempty(config) || ~isstruct(config) || ~isfield(config, 'name')
    config = newRecord;
else
    isExisting = strcmp({config.name}, newRecord.name);
    if any(isExisting)
        insertIndex = find(isExisting, 1, 'first');
    else
        insertIndex = numel(config) + 1;
    end
    config(insertIndex) = newRecord;
end

%% Write back the new config. after success.
tbWriteConfig(config, 'configPath', configPath);

