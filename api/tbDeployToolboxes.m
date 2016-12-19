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
% 'configPath'), or 'toolbox_config.json' in the userpath() folder.
%
% tbDeployToolboxes( ... 'config', config) specify an explicit config
% struct to use instead of reading config from file.
%
% tbDeployToolboxes(... 'toolboxRoot', toolboxRoot) specifies the
% toolboxRoot folder to set the path for.  The default location is
% getpref('ToolboxToolbox', 'toolboxRoot'), or 'toolboxes' in the
% userpath() folder.
%
% tbDeployToolboxes(... 'reset', reset) specifies how to reset the Matlab
% path before processing the given configuration.  The default is 'as-is',
% don't reset the path at all.  See tbResetMatlabPath().
%
% tbDeployToolboxes( ... 'remove', remove) specifies folders to remove from
% to the Matlab path, after setting the path to the given flavor.  See
% tbResetMatlabPath().
%
% tbDeployToolboxes( ... 'add', add) specifies folders to add to the Matlab
% path, after setting the path to the given flavor.  See
% tbResetMatlabPath().
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
% 'localToolboxHooks' in the userpath() folder.
%
% tbDeployToolboxes(... 'runLocalHooks', runLocalHooks) specifies whether
% to run the local hooks deployed toolboxes (true), or not (false).  The
% default is true, run the local hooks.
%
% tbDeployToolboxes(... 'addToPath', addToPath) specifies whether
% to add deployed toolboxes (true) to the Matlab path, or not (false).  The
% default is true, add toolboxes to the path.
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
parser.addParameter('configPath', tbGetPref('configPath', fullfile(tbUserFolder(), 'toolbox_config.json')), @ischar);
parser.addParameter('config', [], @(c) isempty(c) || isstruct(c));
parser.addParameter('toolboxRoot', tbGetPref('toolboxRoot', fullfile(tbUserFolder(), 'toolboxes')), @ischar);
parser.addParameter('toolboxCommonRoot', tbGetPref('toolboxCommonRoot', '/srv/toolboxes'), @ischar);
parser.addParameter('reset', 'as-is', @ischar);
parser.addParameter('add', '', @ischar);
parser.addParameter('remove', '', @ischar);
parser.addParameter('name', '', @ischar);
parser.addParameter('localHookFolder', tbGetPref('localHookFolder', fullfile(tbUserFolder(), 'localHookFolder')), @ischar);
parser.addParameter('registry', tbGetPref('registry', tbDefaultRegistry()), @(c) isempty(c) || isstruct(c));
parser.addParameter('registered', {}, @iscellstr);
parser.addParameter('runLocalHooks', true, @islogical);
parser.addParameter('addToPath', true, @islogical);
parser.parse(varargin{:});
configPath = parser.Results.configPath;
config = parser.Results.config;
toolboxRoot = tbHomePathToAbsolute(parser.Results.toolboxRoot);
toolboxCommonRoot = tbHomePathToAbsolute(parser.Results.toolboxCommonRoot);
reset = parser.Results.reset;
add = parser.Results.add;
remove = parser.Results.remove;
name = parser.Results.name;
localHookFolder = parser.Results.localHookFolder;
registry = parser.Results.registry;
registered = parser.Results.registered;
runLocalHooks = parser.Results.runLocalHooks;
addToPath = parser.Results.addToPath;


%% Choose explicit config, or load from file.
if isempty(config) || ~isstruct(config) || ~isfield(config, 'name')
    config = tbReadConfig('configPath', configPath);
end


%% Convert registered toolbox names to "include" records.
if ~isempty(registered)
    nRegistered = numel(registered);
    registeredRecords = cell(1, nRegistered);
    for rr = 1:nRegistered
        registeredRecords{rr} = tbToolboxRecord('name', registered{rr});
    end
    registeredConfig = [registeredRecords{:}];
    
    if isempty(config) || ~isstruct(config) || ~isfield(config, 'name')
        config = registeredConfig;
    else
        config = cat(2, config, registeredConfig);
    end
end


%% Single out one toolbox?
if ~isempty(name)
    isName = strcmp(name, {config.name});
    if ~any(isName)
        fprintf('Have configurations with names: %s.\n', sprintf('"%s", ', config.name));
        fprintf('  but none with name "%s".\n', name);
        resolved = [];
        included = [];
        return;
    end
    config = config(isName);
end


%% Get or update the toolbox registry.
registry = tbFetchRegistry('registry', registry, 'doUpdate', true);
if 0 ~= registry.status
    fprintf('Unable to fetch toolbox registry "%s".\n', registry.name);
    fprintf('  command was: %s.\n', registry.command);
    fprintf('  message was: %s\n', registry.message);
    resolved = [];
    included = [];
    return;
end


%% Resolve "include" records into one big, flat config.
[resolved, included] = TbIncludeStrategy.resolveIncludedConfigs(config, registry);
resolved = tbDealField(resolved, 'path', '');
resolved = tbDealField(resolved, 'status', 0);
resolved = tbDealField(resolved, 'message', '');
included = tbDealField(included, 'status', 0);
included = tbDealField(included, 'message', '');

if isempty(resolved)
    fprintf('Unable to resolve any configurations.\n');
    fprintf('  configPath to try loading was: %s\n', configPath);
    fprintf('  explicit config struct contained %d records.\n', numel(config));
    fprintf('  registered toolboxes had names: %s.\n', sprintf('"%s", ', registered{:}));
    fprintf('Proceeding in case there''s a hook or localHook to be run.\n');
end


%% Obtain or update the toolboxes.
if ~isempty(resolved)
    resolved = tbFetchToolboxes(resolved, ...
        'toolboxRoot', toolboxRoot, ...
        'toolboxCommonRoot', toolboxCommonRoot);
end

%% Add each toolbox to the path.
if addToPath
    tbResetMatlabPath(reset, ...
        'add', add, ...
        'remove', remove);
    
    % add toolboxes one at a time
    % so we don't add extra cruft that might be in the toolboxRoot folder
    nToolboxes = numel(resolved);
    for tt = 1:nToolboxes
        record = resolved(tt);
        
        % add shared toolbox to path?
        toolboxPath = commonOrNormalPath(toolboxCommonRoot, toolboxRoot, record, true);
        if 7 == exist(toolboxPath, 'dir')
            fprintf('Adding "%s" to path at "%s".\n', record.name, toolboxPath);
            record.strategy.addToPath(record, toolboxPath);
        end
    end
end


%% Set up and invoke "local" hooks with machine-specific setup.
if runLocalHooks
    if ~isempty(localHookFolder) && 7 ~= exist(localHookFolder, 'dir')
        mkdir(localHookFolder);
    end
    
    % resolved toolboxes that were actually deployed
    nToolboxes = numel(resolved);
    for tt = 1:nToolboxes
        resolved(tt) = invokeLocalHook(toolboxCommonRoot, toolboxRoot, localHookFolder, resolved(tt));
    end
    
    % included toolboxes that were not deployed but might have local hooks anyway
    alreadyRun = ismember(tbCollectField(included, 'name', 'template', {}), tbCollectField(resolved, 'name', 'template', {}));
    for tt = find(~alreadyRun)
        included(tt) = invokeLocalHook(toolboxCommonRoot, toolboxRoot, localHookFolder, included(tt));
    end
end


%% Invoke portable, non-local post-deploy hooks.
nToolboxes = numel(resolved);
for tt = 1:nToolboxes
    record = resolved(tt);
    [~, toolboxName] = commonOrNormalPath(toolboxCommonRoot, toolboxRoot, record, false);
    if ~isempty(record.hook) && 2 ~= exist(record.hook, 'file')
        fprintf('Running hook for "%s": "%s".\n', toolboxName, record.hook);
        [resolved(tt).status, resolved(tt).message] = evalIsolated(record.hook);
    end
end


%% How did it go?
resolved = reviewRecords(resolved);
if ~isempty(resolved)
    if all(tbCollectField(resolved, 'isOk', 'template', []))
        fprintf('Looks good: %d resolved toolboxes deployed OK.\n', numel(resolved));
    else
        fprintf('Something went wrong with resolved toolboxes, please see above.\n');
    end
end

if ~isempty(included)
    included = reviewRecords(included);
    if ~all(tbCollectField(included, 'isOk', 'template', []))
        fprintf('Something went wrong with included toolboxes, please see above.\n');
    end
end


%% Choose a shared or normal path for the toolbox.
function [toolboxPath, displayName] = commonOrNormalPath(toolboxCommonRoot, toolboxRoot, record, withSubfolder)
strategy = tbChooseStrategy(record);
[toolboxPath, displayName] = strategy.toolboxPath(toolboxCommonRoot, record, 'withSubfolder', withSubfolder);
if 7 == exist(toolboxPath, 'dir')
    return;
end

[toolboxPath, displayName] = strategy.toolboxPath(toolboxRoot, record, 'withSubfolder', withSubfolder);
if 7 == exist(toolboxPath, 'dir')
    return;
end

toolboxPath = '';


%% Invoke a local hook, create if necessary.
function record = invokeLocalHook(toolboxCommonRoot, toolboxRoot, localHookFolder, record)
[toolboxPath, hookName] = commonOrNormalPath(toolboxCommonRoot, toolboxRoot, record, false);
fprintf('Checking for "%s" local hook.\n', hookName);

% create a local hook if missing and a template exists
templateLocalHookPath = fullfile(toolboxPath, record.localHookTemplate);
existingLocalHookPath = fullfile(localHookFolder, [hookName '.m']);
if 2 ~= exist(existingLocalHookPath, 'file') && 2 == exist(templateLocalHookPath, 'file');
    fprintf('  Creating local hook from template "%s".\n', templateLocalHookPath);
    copyfile(templateLocalHookPath, existingLocalHookPath);
end

% invoke the local hook if it exists
if 2 == exist(existingLocalHookPath, 'file')
    fprintf('  Running local hook "%s".\n', existingLocalHookPath);
    command = ['run ' existingLocalHookPath];
    [record.status, record.message] = evalIsolated(command);
    
    if 0 == record.status
        fprintf('  Hook success with status 0.\n');
    else
        fprintf('  Hook had an error with status %d and result "%s".\n', ...
            record.status, record.message);
    end
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
isSuccess = 0 == tbCollectField(records, 'status', 'template', []);
isOptional = strcmp(tbCollectField(records, 'importance', 'template', {}), 'optional');

isSkipped = ~isSuccess & isOptional;
for tt = find(isSkipped)
    record = records(tt);
    fprintf('Skipped: "%s" had status %d, message "%s"\n', ...
        record.name, record.status, strtrim(record.message));
end

isError = ~isSuccess & ~isOptional;
records = tbDealField(records, 'isOk', true);
for tt = find(isError)
    record = records(tt);
    fprintf('Error: "%s" had status %d, message "%s"\n', ...
        record.name, record.status, strtrim(record.message));
    records(tt).isOk = false;
end

