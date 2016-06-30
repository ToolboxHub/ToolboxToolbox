function results = tbFetchToolboxes(config, varargin)
% Read toolbox configuration from a file.
%
% The idea is to work through elements of the given toolbox configuration
% struct, and for each element fetch or update the indicated toolbox.
%
% results = tbFetchToolboxes(config) fetches or updates each of the
% toolboxes named in the given config struct (see tbReadConfig).  Each
% toolbox will be located in a subfolder of the default toolbox root
% folder.
%
% tbFetchToolboxes( ... 'toolboxRoot', toolboxRoot) specify where to fetch
% toolboxes.  The default location is '~/toolboxes'.
%
% As an optimization for shares systems, toolboxes may be pre-deployed
% (probably by an admin) to a common toolbox root folder.  Toolboxes found
% here will be updated, instead of being installed to the given
% toolboxRoot.
%
% tbFetchToolboxes( ... 'toolboxCommonRoot', toolboxCommonRoot) specify
% where to look for shared toolboxes.  The default location is
% '/srv/toolbox-toolbox/toolboxes'.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addRequired('config', @isstruct);
parser.addParameter('toolboxRoot', '~/toolboxes', @ischar);
parser.addParameter('toolboxCommonRoot', '/srv/toolbox-toolbox/toolboxes', @ischar);
parser.addParameter('restorePath', false, @islogical);
parser.parse(config, varargin{:});
toolboxRoot = tbHomePathToAbsolute(parser.Results.toolboxRoot);
toolboxCommonRoot = tbHomePathToAbsolute(parser.Results.toolboxCommonRoot);

results = config;
[results.command] = deal('');
[results.status] = deal([]);
[results.result] = deal('skipped');

%% Make sure we have a place to put toolboxes.
if 7 ~= exist(toolboxRoot, 'dir')
    mkdir(toolboxRoot);
end

%% Fetch or update each toolbox.
nToolboxes = numel(results);
for tt = 1:nToolboxes
    record = tbToolboxRecord(config(tt));
    if isempty(record.name)
        results(tt).status = -1;
        results(tt).command = '';
        results(tt).result = 'no toolbox name given';
        continue;
    end
    
    toolboxCommonFolder = fullfile(toolboxCommonRoot, record.name);
    toolboxFolder = fullfile(toolboxRoot, record.name);
    if 7 == exist(toolboxCommonFolder, 'dir')
        fprintf('Updating shared toolbox "%s" at "%s"\n', record.name, toolboxCommonFolder);
        results(tt) = updateToolbox(record, toolboxCommonFolder);
        
    elseif 7 == exist(toolboxFolder, 'dir')
        fprintf('Updating toolbox "%s" at "%s"\n', record.name, toolboxFolder);
        results(tt) = updateToolbox(record, toolboxFolder);
        
    else
        fprintf('Fetching toolbox "%s" into "%s"\n', record.name, toolboxFolder);
        results(tt) = obtainToolbox(record, toolboxRoot, toolboxFolder);
    end
end

%% Obtain a toolbox that that was not yet deployed.
function result = obtainToolbox(record, toolboxRoot, toolboxFolder)
result = record;

% clone
cloneCommand = sprintf('git -C "%s" clone "%s" "%s"', toolboxRoot, record.url, record.name);
[cloneStatus, cloneResult] = system(cloneCommand);
result.command = cloneCommand;
result.status = cloneStatus;
result.result = cloneResult;
if 0 ~= cloneStatus
    return;
end

if ~isempty(record.ref)
    fetchCommand = sprintf('git -C "%s" fetch origin +%s:%s', toolboxFolder, record.ref, record.ref);
    [fetchStatus, fetchResult] = system(fetchCommand);
    result.command = fetchCommand;
    result.status = fetchStatus;
    result.result = fetchResult;
    if 0 ~= fetchStatus
        return;
    end
    
    checkoutCommand = sprintf('git -C "%s" checkout %s', toolboxFolder, record.ref);
    [checkoutStatus, checkoutResult] = system(checkoutCommand);
    result.command = checkoutCommand;
    result.status = checkoutStatus;
    result.result = checkoutResult;
    if 0 ~= checkoutStatus
        return;
    end
end

%% Update a toolbox that was already deployed.
function result = updateToolbox(record, toolboxFolder)
% update the toolbox with git
if isempty(record.ref)
    command = sprintf('git -C "%s" pull', toolboxFolder);
else
    command = sprintf('git -C "%s" pull origin %s', toolboxFolder, record.ref);
end
[status, commandResult] = system(command);

result = record;
result.command = command;
result.status = status;
result.result = commandResult;
