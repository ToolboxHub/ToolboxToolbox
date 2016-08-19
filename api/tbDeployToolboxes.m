function [resolved, included] = tbDeployToolboxes(varargin)
% Fetch toolboxes and add them to the Matlab path.
%
% results = tbDeployToolboxes() fetches each toolbox from the default
% toolbox configuration adds each to the Matlab path.  Returns a struct of
% results about what happened for each toolbox.
%
% [resolved, included] = tbDeployToolboxes( ... ) returns a struct of
% results about what happened for each toolbox that was actually resolved
% and deployed, and also for each "include" toolbox which was a pointer to
% other toolboxes.
%
% tbDeployToolboxes( ... 'configPath', configPath) specify where to look
% for the config file.  The default location is getpref('ToolboxToolbox',
% 'configPath'), or '~/toolbox_config.json'.
%
% tbDeployToolboxes( ... 'config', config) specify an explicit config
% struct to use instead of reading config from file.
%
% tbDeployToolboxes(... 'toolboxRoot', toolboxRoot) specifies the
% toolboxRoot folder to set the path for.  The default location is
% getpref('ToolboxToolbox', 'toolboxRoot'), or '~/toolboxes'.
%
% tbDeployToolboxes(... 'reset', reset) specifies how to reset the Matlab
% path before processing the given configuration.  The default is 'as-is',
% don't reset the path at all.  See tbResetMatlabPath().
%
% tbDeployToolboxes(... 'name', name) specify the name of a single toolbox
% to deploy if found.  Other toolboxes will be ignored.
%
% tbDeployToolboxes( ... 'registry', registry) specify an explicit toolbox
% record which indicates where and how to access a registry of shared
% toolbox configurations.  The default is getpref('ToolboxToolbox',
% 'registry'), or the public registry at Toolbox Hub.
%
% tbDeployToolboxes( ... 'registered', registered) specify a cell array of
% toolbox names to be resolved in the given registry or the public registry
% at Toolbox Hub.  These will be added to the given config, if any.
%
% tbDeployToolboxes(... 'localHookFolder', localHookFolder) specifies the
% path to the folder that contains local hook scripts.  The default
% location is getpref('ToolboxToolbox', 'localHookFolder'), or
% '~/toolboxes/localHooks'.
%
% As an optimization for shared systems, toolboxes may be pre-deployed
% (probably by an admin) to a common toolbox root folder.  Toolboxes found
% here will be added to the path instead of toolboxes in the given
% toolboxRoot.
%
% tbFetchToolboxes( ... 'toolboxCommonRoot', toolboxCommonRoot) specify
% where to look for shared toolboxes. The default location is
% getpref('ToolboxToolbox', 'toolboxCommonRoot'), or '/srv/toolboxes'.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addParameter('configPath', tbGetPref('configPath', '~/toolbox_config.json'), @ischar);
parser.addParameter('config', [], @(c) isempty(c) || isstruct(c));
parser.addParameter('toolboxRoot', tbGetPref('toolboxRoot', '~/toolboxes'), @ischar);
parser.addParameter('toolboxCommonRoot', tbGetPref('toolboxCommonRoot', '/srv/toolboxes'), @ischar);
parser.addParameter('reset', 'as-is', @ischar);
parser.addParameter('name', '', @ischar);
parser.addParameter('localHookFolder', tbGetPref('localHookFolder', '~/localToolboxHooks'), @ischar);
parser.addParameter('registry', tbGetPref('registry', tbDefaultRegistry()), @(c) isempty(c) || isstruct(c));
parser.addParameter('registered', {}, @iscellstr);
parser.parse(varargin{:});
configPath = parser.Results.configPath;
config = parser.Results.config;
toolboxRoot = tbHomePathToAbsolute(parser.Results.toolboxRoot);
toolboxCommonRoot = tbHomePathToAbsolute(parser.Results.toolboxCommonRoot);
reset = parser.Results.reset;
name = parser.Results.name;
localHookFolder = parser.Results.localHookFolder;
registry = parser.Results.registry;
registered = parser.Results.registered;

%% Choose explicit config, or load from file.
if isempty(config) || ~isstruct(config) || ~isfield(config, 'name')
    config = tbReadConfig('configPath', configPath);
end

%% Include toolboxes by name from registry.
if ~isempty(registered)
    nRegistered = numel(registered);
    registeredRecords = cell(1, nRegistered);
    for rr = 1:nRegistered
        registeredRecords{rr} = tbToolboxRecord('name', registered{rr});
    end
    
    if isempty(config) || ~isstruct(config) || ~isfield(config, 'name')
        config = [registeredRecords{:}];
    else
        config = cat(2, config, [registeredRecords{:}]);
    end
end

if isempty(config) || ~isstruct(config) || ~isfield(config, 'name')
    resolved = [];
    included = [];
    return;
end


%% Single out one toolbox?
if ~isempty(name)
    isName = strcmp(name, {config.name});
    if ~any(isName)
        resolved = [];
        included = [];
        return;
    end
    config = config(isName);
end

%% Resolve "include" records into one big, flat config.
tbFetchRegistry('registry', registry, 'doUpdate', true);
[resolved, included] = TbIncludeStrategy.resolveIncludedConfigs(config, registry);


%% Obtain or update the toolboxes.
resolved = tbFetchToolboxes(resolved, ...
    'toolboxRoot', toolboxRoot, ...
    'toolboxCommonRoot', toolboxCommonRoot);


%% Add each toolbox to the path.
tbResetMatlabPath(reset);

% add toolboxes one at a time 
% so we don't add extra cruft that might be in the toolboxRoot folder
[resolved.path] = deal('');
nToolboxes = numel(resolved);
for tt = 1:nToolboxes
    record = resolved(tt);
    
    % add shared toolbox to path?
    toolboxPath = commonOrNormalPath(toolboxCommonRoot, toolboxRoot, record);
    if 7 == exist(toolboxPath, 'dir')
        fprintf('Adding "%s" to path at "%s".\n', record.name, toolboxPath);
        record.strategy.addToPath(record, toolboxPath);
    end
end

%% Set up and invoke "local" hooks with machine-specific setup.
if ~isempty(localHookFolder) && 7 ~= exist(localHookFolder, 'dir')
    mkdir(localHookFolder);
end

% resolved toolboxes that were actually deployed
nToolboxes = numel(resolved);
for tt = 1:nToolboxes
    resolved(tt) = invokeLocalHook(toolboxCommonRoot, toolboxRoot, localHookFolder, resolved(tt));
end

% included toolboxes that were not deployed but might have local hooks anyway
[included.status] = deal(0);
[included.message] = deal('');
alreadyRun = ismember({included.name}, {resolved.name});
for tt = find(~alreadyRun)
    included(tt) = invokeLocalHook(toolboxCommonRoot, toolboxRoot, localHookFolder, included(tt));
end


%% Invoke portable, non-local post-deploy hooks.
nToolboxes = numel(resolved);
for tt = 1:nToolboxes
    record = resolved(tt);
    [~, hookName] = commonOrNormalPath(toolboxCommonRoot, toolboxRoot, record);
    if ~isempty(record.hook) && 2 ~= exist(record.hook, 'file')
        fprintf('Running hook for "%s": "%s".\n', hookName, record.hook);
        [resolved(tt).status, resolved(tt).message] = evalIsolated(record.hook);
    end
end


%% How did it go?
resolved = reviewRecords(resolved);
included = reviewRecords(included);
if all([resolved.isOk]) && all([included.isOk])
    fprintf('Looks good: all toolboxes deployed OK.\n');
else
    fprintf('Something went wrong, please see above.\n');
end


%% Choose a shared or normal path for the toolbox.
function [toolboxPath, displayName] = commonOrNormalPath(toolboxCommonRoot, toolboxRoot, record)
strategy = tbChooseStrategy(record);
[toolboxPath, displayName] = strategy.toolboxPath(toolboxCommonRoot, record, 'withSubfolder', true);
if 7 == exist(toolboxPath, 'dir')
    return;
end

[toolboxPath, displayName] = strategy.toolboxPath(toolboxRoot, record, 'withSubfolder', true);
if 7 == exist(toolboxPath, 'dir')
    return;
end

toolboxPath = '';


%% Invoke a local hook, create if necessary.
function record = invokeLocalHook(toolboxCommonRoot, toolboxRoot, localHookFolder, record)
rehash;

% create a local hook if missing and a template exists
[toolboxPath, hookName] = commonOrNormalPath(toolboxCommonRoot, toolboxRoot, record);
templateLocalHookPath = fullfile(toolboxPath, record.localHookTemplate);
existingLocalHookPath = fullfile(localHookFolder, [hookName '.m']);
if 2 ~= exist(existingLocalHookPath, 'file') && 2 == exist(templateLocalHookPath, 'file');
    fprintf('Creating local hook from template for "%s": "%s".\n', hookName, templateLocalHookPath);
    copyfile(templateLocalHookPath, existingLocalHookPath);
end

% invoke the local hook if it exists
if 2 == exist(existingLocalHookPath, 'file')
    fprintf('Running local hook for "%s": "%s".\n', hookName, existingLocalHookPath);
    command = ['run ' existingLocalHookPath];
    [record.status, record.message] = evalIsolated(command);
end


%% Evaluate an expression, don't cd or clear.
function [status, message] = evalIsolated(expression)
originalDir = pwd();
[status, message] = evalPrivateWorkspace(expression);
cd(originalDir);


%% Evaluate an expression, don't clear.
function [status, message] = evalPrivateWorkspace(expression)
try
    message = evalc(expression);
    status = 0;
catch err
    status = -1;
    message = err.message;
end


%% Display errors and warnings for each record.
function records = reviewRecords(records)
isSuccess = 0 == [records.status];
isOptional = strcmp({records.importance}, 'optional');

isSkipped = ~isSuccess & isOptional;
for tt = find(isSkipped)
    record = records(tt);
    fprintf('Skipped: "%s" had status %d, message "%s"\n', ...
        record.name, record.status, strtrim(record.message));
end

isError = ~isSuccess & ~isOptional;
[records.isOk] = deal(true);
for tt = find(isError)
    record = records(tt);
    fprintf('Error: "%s" had status %d, message "%s"\n', ...
        record.name, record.status, strtrim(record.message));
    records(tt).isOk = false;
end

