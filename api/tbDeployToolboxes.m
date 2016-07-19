function results = tbDeployToolboxes(varargin)
% Fetch toolboxes and add them to the Matlab path.
%
% The goal here is to make it a one-liner to fetch toolboxes and add them
% to the Matlab path.  This should automate several steps that we usually
% do by hand, which is good for consistency and convenience.
%
% results = tbDeployToolboxes() fetches each toolbox from the default
% toolbox configuration adds each to the Matlab path.  Returns a struct of
% results about what happened for each toolbox.
%
% tbReadConfig( ... 'configPath', configPath) specify where to look for the
% config file.  The default location is getpref('ToolboxToolbox',
% 'configPath'), or '~/toolbox_config.json'.
%
% tbReadConfig( ... 'config', config) specify an explicit config struct to
% use instead of reading config from file.
%
% tbDeployToolboxes(... 'toolboxRoot', toolboxRoot) specifies the
% toolboxRoot folder to set the path for.  The default location is
% getpref('ToolboxToolbox', 'toolboxRoot'), or '~/toolboxes'.
%
% tbDeployToolboxes(... 'restorePath', restorePath) specifies whether to
% restore the default Matlab path before setting up the toolbox path.  The
% default is false, just add to the existing path.
%
% tbDeployToolboxes(... 'withInstalled', withInstalled) specifies whether
% to include installed matlab toolboxes.  This only has an effect when
% restorePath is true.  The default is true, include all installed
% toolboxes on the path.
%
% tbDeployToolboxes(... 'name', name) specify the name of a single toolbox
% to deploy if found.  Other toolboxes will be ignored.
%
% As an optimization for shares systems, toolboxes may be pre-deployed
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
parser.addParameter('restorePath', false, @islogical);
parser.addParameter('withInstalled', true, @islogical);
parser.addParameter('name', '', @ischar);
parser.parse(varargin{:});
configPath = parser.Results.configPath;
config = parser.Results.config;
toolboxRoot = tbHomePathToAbsolute(parser.Results.toolboxRoot);
toolboxCommonRoot = tbHomePathToAbsolute(parser.Results.toolboxCommonRoot);
restorePath = parser.Results.restorePath;
withInstalled = parser.Results.withInstalled;
name = parser.Results.name;

%% Choose explicit config, or load from file.
if isempty(config) || ~isstruct(config) || ~isfield(config, 'name')
    config = tbReadConfig('configPath', configPath);
    
    if isempty(config) || ~isstruct(config) || ~isfield(config, 'name')
        results = config;
        return;
    end
end

%% Single out one toolbox?
if ~isempty(name)
    isName = strcmp(name, {config.name});
    if ~any(isName)
        results = config;
        return;
    end
    config = config(isName);
end

%% Obtain or update the toolboxes.
results = tbFetchToolboxes(config, ...
    'toolboxRoot', toolboxRoot, ...
    'toolboxCommonRoot', toolboxCommonRoot);

%% Add each toolbox to the path.
if restorePath
    tbResetMatlabPath( ...
        'withSelf', true, ...
        'withInstalled', withInstalled);
end

% add toolboxes one at a time so that we can check for errors
% and so we don't add extra cruft that might be in the toolboxRoog folder
nToolboxes = numel(results);
for tt = 1:nToolboxes
    record = results(tt);
    results(tt).path = '';
    
    % don't add errored toolbox to path
    if record.status ~= 0
        continue;
    end
    
    % add shared toolbox to path?
    strategy = results(tt).strategy;
    toolboxSharedPath = strategy.toolboxPath(toolboxCommonRoot, record, 'withSubfolder', true);
    if 7 == exist(toolboxSharedPath, 'dir')
        results(tt).path = toolboxSharedPath;
        fprintf('Adding "%s" to path at "%s".\n', record.name, toolboxSharedPath);
        tbSetToolboxPath('toolboxPath', toolboxSharedPath, 'restorePath', false);
        continue;
    end
    
    % add regular toolbox to path?
    toolboxPath = strategy.toolboxPath(toolboxRoot, record, 'withSubfolder', true);
    if 7 == exist(toolboxPath, 'dir')
        results(tt).path = toolboxPath;
        fprintf('Adding "%s" to path at "%s".\n', record.name, toolboxPath);
        tbSetToolboxPath('toolboxPath', toolboxPath, 'restorePath', false);
        continue;
    end
end

%% Invoke Post-Deploy hooks.
nToolboxes = numel(results);
for tt = 1:nToolboxes
    record = results(tt);
    if record.status ~= 0
        continue;
    end
    
    if ~isempty(record.hook)
        fprintf('Running hook for "%s": "%s".\n', record.name, record.hook);
        [results(tt).status, results(tt).message] = evalIsolated(record.hook);
    end
end

%% How did it go?
isSuccess = 0 == [results.status];
if all(isSuccess)
    fprintf('Looks good: all toolboxes deployed with status 0.\n');
else
    errorIndexes = find(~isSuccess);
    fprintf('The following toolboxes had nonzero status:\n');
    for tt = errorIndexes
        record = results(tt);
        fprintf('  "%s": status %d, message "%s"\n', ...
            record.name, record.status, record.message);
    end
end

%% Evaluate an expression, don't cd or clear.
function [status, message] = evalIsolated(expression)
originalDir = pwd();
[status, message] = evalPrivateWorkspace(expression);
cd(originalDir);

%% Evaluate an expression, don't clear.
function [status, message] = evalPrivateWorkspace(expression)
status = -1;
try
    message = evalc(expression);
    status = 0;
catch err
    message = err.message;
end
