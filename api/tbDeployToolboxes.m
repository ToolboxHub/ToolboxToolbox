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
% This function uses ToolboxToolbox shared parameters and preferences.  See
% tbParsePrefs().
%
% tbDeployToolboxes(... 'config', config) deploy the given struct array of
% toolbox records instead of the default toolbox configuration.
%
% tbDeployToolboxes(... 'name', name) specify the name of a single toolbox
% to deploy if found.  Other toolboxes will be ignored.
%
% tbDeployToolboxes( ... 'registered', registered) specify a cell array of
% toolbox names to be resolved in the given registry or the public registry
% at Toolbox Hub.  These will be added to the given config, if any.
%
% 2016 benjamin.heasly@gmail.com

% 6/24/17  dhb  Handle special # syntax for toolboxRoot.

[prefs, others] = tbParsePrefs(varargin{:});

parser = inputParser();
parser.addParameter('config', [], @(c) isempty(c) || isstruct(c));
parser.addParameter('name', '', @ischar);
parser.addParameter('registered', {}, @iscellstr);
parser.parse(others);
name = parser.Results.name;
registered = parser.Results.registered;
config = parser.Results.config;


%% Share the current prefs with user-defined hooks invoked below.
tbCurrentPrefs(prefs);


%% Choose explicit config, or load from file.
if isempty(config) || ~isstruct(config) || ~isfield(config, 'name')
    config = tbReadConfig(prefs);
end

%% Check whether TbTb itself is up-to-date, and report status
self = tbToolboxRecord( ...
    'toolboxRoot', fileparts(tbLocateSelf()), ...
    'name', 'ToolboxToolbox', ...
    'type', 'git');
strategy = tbChooseStrategy(self, prefs);
[flavor,flavorlong,originflavorlong] = strategy.detectFlavor(self);
if (isempty(flavorlong))
    if (prefs.verbose) fprintf(2,'Cannot detect local ToolboxToolbox revision number and thus cannot tell if it is up to date\n\n'); end
elseif (isempty(originflavorlong))
    if (prefs.verbose) fprintf(2,'Cannot detect ToolboxToolbox revision number on gitHub and thus cannot tell if local copy is up to date\n\n'); end
elseif (strcmp(flavorlong,originflavorlong))
    if (prefs.verbose) fprintf('Local copy of ToolboxToolbox is up to date.\n'); end
else
    if (prefs.verbose) fprintf(2,'Local copy of ToolboxTooblox out of date (or you made local modifications).\n'); end
    if (prefs.verbose) fprintf(2,'Consider updating with git pull or otherwise synchronizing.\n\n'); end
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

%% Ignore records without names -- they're just comments.
if ~isempty(config)
    isComment = cellfun(@isempty, {config.name});
    config = config(~isComment);
end

%% Single out one toolbox?
if ~isempty(name)
    isName = strcmp(name, {config.name});
    if ~any(isName)
        if (prefs.verbose)
            fprintf('Have configurations with names: %s.\n', sprintf('"%s", ', config.name));
            fprintf('  but none with name "%s".\n', name);
        end
        resolved = [];
        included = [];
        return;
    end
    config = config(isName);
end


%% Get or update the toolbox registry.
registry = tbFetchRegistry(prefs, 'doUpdate', true);
if 0 ~= registry.status
    registryPath = tbLocateToolbox(registry, prefs);
    if isempty(registryPath)
        if (prefs.verbose)   
            fprintf('Unable to fetch toolbox registry "%s".\n', registry.name);
            fprintf('  command was: %s.\n', registry.command);
            fprintf('  message was: %s\n', registry.message);
        end
        resolved = [];
        included = [];
        return;
    else
        if (prefs.verbose) fprintf('Unable to update toolbox registry "%s", proceeding with current version.\n', registry.name); end
    end
end


%% Resolve "include" records into one big, flat config.
[resolved, included] = TbIncludeStrategy.resolveIncludedConfigs(config, prefs);
resolved = tbDealField(resolved, 'path', '');
resolved = tbDealField(resolved, 'status', 0);
resolved = tbDealField(resolved, 'message', '');
included = tbDealField(included, 'status', 0);
included = tbDealField(included, 'message', '');

if isempty(resolved)
    if (prefs.verbose)
        fprintf('Unable to resolve any configurations.\n');
        fprintf('  configPath to try loading was: %s\n', prefs.configPath);
        fprintf('  explicit config struct contained %d records.\n', numel(config));
        fprintf('  registered toolboxes had names: %s.\n', sprintf('"%s", ', registered{:}));
        fprintf('Proceeding in case there''s a hook or localHook to be run.\n');
    end
end


%% Obtain or update the toolboxes.
if ~isempty(resolved)
    resolved = tbFetchToolboxes(resolved, prefs);
end

%% Add each toolbox to the path.
if prefs.addToPath
    tbResetMatlabPath(prefs);
    
    nToolboxes = numel(resolved);
    for tt = 1:nToolboxes
        record = resolved(tt);
        
        % Kluge up and handle case where we have a project as toolbox.
        if (~isempty(record.toolboxRoot) & record.toolboxRoot(1) == '#')
            toolboxRoot = tbLocateProject(record.name);
            if (isempty(toolboxRoot))
                error('We think the project should have been fetched by now');
            end
            record.toolboxRoot = fileparts(toolboxRoot);
        end
        
        % base folder for the toolbox
        [toolboxPath, displayName] = tbLocateToolbox(record, prefs);
        
        % any subfolders to use instead of base folder?
        if ischar(record.subfolder)
            subfolders = {record.subfolder};
        elseif iscellstr(record.subfolder)
            subfolders = record.subfolder;
        else
            subfolders = {''};
        end
        
        % add each toolbox folder to the path
        nSubfolders = numel(subfolders);
        for ss = 1:nSubfolders
            pathToAdd = fullfile(toolboxPath, subfolders{ss});
            if 7 == exist(pathToAdd, 'dir')
                if (prefs.verbose) fprintf('Adding "%s" to path at "%s".\n', displayName, pathToAdd); end
                record.strategy.addToPath(record, pathToAdd);
            end
        end
    end
end


%% Set up and invoke "local" hooks with machine-specific setup.
if prefs.runLocalHooks
    if ~isempty(prefs.localHookFolder) && 7 ~= exist(prefs.localHookFolder, 'dir')
        mkdir(prefs.localHookFolder);
    end
    
    % resolved toolboxes that were actually deployed
    nToolboxes = numel(resolved);
    for tt = 1:nToolboxes
        resolved(tt) = invokeLocalHook(resolved(tt), prefs);
    end
    
    % included toolboxes that were not deployed but might have local hooks anyway
    alreadyRun = ismember(tbCollectField(included, 'name', 'template', {}), tbCollectField(resolved, 'name', 'template', {}));
    for tt = find(~alreadyRun)
        included(tt) = invokeLocalHook(included(tt), prefs);
    end
end

%% requirementHook checks dependencies that ToolboxToolbox can't install.
nToolboxes = numel(resolved);
for tt = 1:nToolboxes
    record = resolved(tt);
    [~, toolboxName] = tbLocateToolbox(record, prefs);
    
    if isempty(record.requirementHook)
        continue;
    end
    
    try
        if (prefs.verbose)
            fprintf('Checking requirementHook for "%s": "%s".\n', ...
                toolboxName, record.requirementHook);
        end
        [status, message, advice] = feval(record.requirementHook);
    catch err
        status = -1;
        message = err.message;
        advice = sprintf('Please check that the function "%s" exists and has signature [status, result, advice] = foo()', ...
            record.requirementHook);
    end
    resolved(tt).status = status;
    resolved(tt).message = message;
    
    if 0 == status
        if (prefs.verbose) fprintf('  OK: "%s".\n', message); end
    else
        if (prefs.verbose) fprintf('  Requirement not met: "%s".\n', message); end
        if (prefs.verbose) fprintf('  Suggestion: "%s".\n', advice); end
    end
end


%% Invoke portable, non-local post-deploy hooks.
nToolboxes = numel(resolved);
for tt = 1:nToolboxes
    record = resolved(tt);
    [~, toolboxName] = tbLocateToolbox(record, prefs);
    
    if isempty(record.hook)
        continue;
    end
    
    if (prefs.verbose)
        fprintf('Evaluating general-purpose hook for "%s": "%s".\n', ...
            toolboxName, record.hook);
    end
    [status, message] = evalIsolated(record.hook);
    resolved(tt).status = status;
    resolved(tt).message = message;
    if 0 == status
        if (prefs.verbose) fprintf('  OK: "%s".\n', message); end
    else
        if (prefs.verbose) fprintf('  Hook had an error with status %d and message "%s".\n', status, message); end
    end
end


%% How did it go?
resolved = reviewRecords(resolved,prefs);
if ~isempty(resolved)
    if all(tbCollectField(resolved, 'isOk', 'template', []))
        if (prefs.verbose) fprintf('Looks good: %d resolved toolboxes deployed OK.\n', numel(resolved)); end
    else
        if (prefs.verbose) fprintf('Something went wrong with resolved toolboxes, please see above.\n'); end
    end
end

if ~isempty(included)
    included = reviewRecords(included,prefs);
    if ~all(tbCollectField(included, 'isOk', 'template', []))
        if (prefs.verbose) fprintf('Something went wrong with included toolboxes, please see above.\n'); end
    end
end


%% Invoke a local hook, create if necessary.
function record = invokeLocalHook(record, prefs)
[toolboxPath, hookName] = tbLocateToolbox(record, prefs);
if (prefs.verbose) fprintf('Checking for "%s" local hook.\n', hookName); end

% look for Foo.m or FooLocalHook.m
simpleHookPath = fullfile(prefs.localHookFolder, [hookName '.m']);
simpleHookExists = 2 == exist(simpleHookPath, 'file');
explicitHookPath = fullfile(prefs.localHookFolder, [hookName 'LocalHook.m']);
explicitHookExists = 2 == exist(explicitHookPath, 'file');

% create a local hook if missing and a template exists
templatePath = fullfile(toolboxPath, record.localHookTemplate);
templateExists = 2 == exist(templatePath, 'file');
if ~simpleHookExists && ~explicitHookExists && templateExists
    if (prefs.verbose) fprintf('  Creating local hook from template "%s".\n', templatePath); end
    copyfile(templatePath, explicitHookPath);
    explicitHookExists = true;
end

% which hook exists, if any?
if explicitHookExists
    hookPath = explicitHookPath;
elseif simpleHookExists
    hookPath = simpleHookPath;
else
    hookPath = '';
end

% invoke the local hook if it exists
if ~isempty(hookPath);
    if (prefs.verbose) fprintf('  Running local hook "%s".\n', hookPath); end
    command = ['run ' hookPath];
    [record.status, record.message] = evalIsolated(command);
    
    if 0 == record.status
        if (prefs.verbose) fprintf('  Hook success with status 0.\n'); end
    else
        if (prefs.verbose)
            fprintf('  Hook had an error with status %d and result "%s".\n', ...
            record.status, record.message);
        end
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
function records = reviewRecords(records,prefs)
isSuccess = 0 == tbCollectField(records, 'status', 'template', []);
isOptional = strcmp(tbCollectField(records, 'importance', 'template', {}), 'optional');

isSkipped = ~isSuccess & isOptional;
for tt = find(isSkipped)
    record = records(tt);
    if (prefs.verbose)
        fprintf('Skipped: "%s" had status %d, message "%s"\n', ...
            record.name, record.status, strtrim(record.message));
    end
end

isError = ~isSuccess & ~isOptional;
records = tbDealField(records, 'isOk', true);
for tt = find(isError)
    record = records(tt);
    if (prefs.verbose)
        fprintf('Error: "%s" had status %d, message "%s"\n', ...
            record.name, record.status, strtrim(record.message));
    end
    records(tt).isOk = false;
end

