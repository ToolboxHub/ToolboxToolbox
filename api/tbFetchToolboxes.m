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
% tbFetchToolboxes( ... 'toolboxRoot', toolboxRoot) specify where to put
% toolboxes.  The default location is
% getpref('ToolboxToolbox', 'toolboxRoot'), or '~/toolboxes'.
%
% As an optimization for shared systems, toolboxes may be pre-deployed
% (by an admin) to a common toolbox root folder.  Toolboxes found here will
% be updated, instead of being installed to the given toolboxRoot.
%
% tbFetchToolboxes( ... 'toolboxCommonRoot', toolboxCommonRoot) specify
% where to look for shared toolboxes.  The default location is
% getpref('ToolboxToolbox', 'toolboxCommonRoot'), or '/srv/toolboxes'.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addRequired('config', @isstruct);
parser.addParameter('toolboxRoot', tbGetPref('toolboxRoot', '~/toolboxes'), @ischar);
parser.addParameter('toolboxCommonRoot', tbGetPref('toolboxCommonRoot', '/srv/toolboxes'), @ischar);
parser.addParameter('restorePath', false, @islogical);
parser.parse(config, varargin{:});
toolboxRoot = tbHomePathToAbsolute(parser.Results.toolboxRoot);
toolboxCommonRoot = tbHomePathToAbsolute(parser.Results.toolboxCommonRoot);

results = config;
[results.operation] = deal('skipped');
[results.command] = deal('');
[results.status] = deal(0);
[results.message] = deal('');

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
        results(tt).message = 'no toolbox name given';
        continue;
    end
    
    % what kind of toolbox is this
    strategy = tbChooseStrategy(record);
    if isempty(strategy)
        results(tt).status = -1;
        results(tt).command = 'tbChooseStrategy';
        results(tt).message = sprintf('Unknown toolbox type %s', record.type);
        continue;
    end
    
    % is the toolbox pre-installed in the common location?
    [toolboxCommonFolder, displayName] = tbToolboxPath(toolboxCommonRoot, record);
    if strategy.checkIfPresent(record, toolboxCommonRoot, toolboxCommonFolder);
        if strcmp(record.update, 'never')
            continue;
        end
        
        fprintf('Updating "%s".\n', displayName);
        results(tt).operation = 'update';
        [results(tt).command, results(tt).status, results(tt).message] = ...
            strategy.update(record, toolboxCommonRoot, toolboxCommonFolder);
        continue;
    end
    
    % is the toolbox alredy in the refular location?
    [toolboxFolder, displayName] = tbToolboxPath(toolboxRoot, record);
    if strategy.checkIfPresent(record, toolboxRoot, toolboxFolder);
        if strcmp(record.update, 'never')
            continue;
        end
        
        fprintf('Updating "%s".\n', displayName);
        results(tt).operation = 'update';
        [results(tt).command, results(tt).status, results(tt).message] = ...
            strategy.update(record, toolboxRoot, toolboxFolder);
        continue;
    end
    
    % obtain the toolbox
    fprintf('Obtaining "%s".\n', displayName);
    results(tt).operation = 'obtain';
    [results(tt).command, results(tt).status, results(tt).message] = ...
        strategy.obtain(record, toolboxRoot, toolboxFolder);
end
