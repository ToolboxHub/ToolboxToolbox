function results = tbFetchToolboxes(config, persistentPrefs, varargin)
% Read toolbox configuration from a file.
%
% The idea is to work through elements of the given toolbox configuration
% struct, and for each element fetch or update the indicated toolbox.
%
% results = tbFetchToolboxes(config) fetches or updates each of the
% toolboxes named in the given config struct (see tbReadConfig).  Each
% toolbox will be located in a subfolder of the configured toolboxRoot or
% toolboxCommonRoot folder.
%
% This function uses ToolboxToolbox shared parameters and preferences.  See
% tbParsePrefs().
%
% 2016 benjamin.heasly@gmail.com

% 6/24/17  dhb  Add # syntax for dealing with projects that we want to
%               treat as toolboxes, while also treating them as independent projects.

prefs = tbParsePrefs(persistentPrefs, varargin{:});

parser = inputParser();
parser.addRequired('config', @isstruct);
parser.parse(config);
config = parser.Results.config;

results = config;
results = tbDealField(results, 'operation', 'skipped');
results = tbDealField(results, 'command', '');
results = tbDealField(results, 'status', 0);
results = tbDealField(results, 'message', '');
results = tbDealField(results, 'strategy', []);

%% Fetch or update each toolbox.
nToolboxes = numel(results);
for tt = 1:nToolboxes
    record = tbToolboxRecord(config(tt));
    if isempty(record.name)
        re
        tbsults(tt).status = -1;
        results(tt).command = '';
        results(tt).message = 'no toolbox name given';
        continue;
    end
    
    % what kind of toolbox is this?
    strategy = tbChooseStrategy(record, persistentPrefs, prefs);
    if isempty(strategy)
        results(tt).status = -1;
        results(tt).command = 'tbChooseStrategy';
        results(tt).message = sprintf('Unknown toolbox type %s', record.type);
        continue;
    end
    results(tt).strategy = strategy;
    
    % make sure the toolbox destination exists
    if isempty(record.toolboxRoot)
        % put this toolbox with all the other toolboxes
        obtainRoot = prefs.toolboxRoot;
    elseif (record.toolboxRoot(1) == '#')
        % If there is a toolbox with this name under projects, use its location.
        % Otherwise get it and put it in the specified place under the projects directory.
        obtainRoot = tbLocateProject(record.name);
        if (isempty(obtainRoot))
            if length(record.toolboxRoot == 1)
                obtainRoot = fullfile(prefs.toolboxRoot,'..','projects');
            else
                obtainRoot = fullfile(prefs.toolboxRoot,'..','projects',record.toolboxRoot(2:end));
            end
        else
            obtainRoot = fileparts(obtainRoot);
        end
        record.toolboxRoot = obtainRoot;
    elseif strcmp(record.toolboxRoot,'userpath')
        obtainRoot = userpath;
    else
        % put the toolbox in the specified special place.
        obtainRoot = tbHomePathToAbsolute(record.toolboxRoot);  
    end
        
    if 7 ~= exist(obtainRoot, 'dir')
        mkdir(obtainRoot);
    end
    
    % look for the toolbox
    [updatePath, displayName, updateRoot] = tbLocateToolbox(record, prefs);
    if isempty(updatePath)
        % obtain the toolbox
        if (prefs.verbose) fprintf('Obtaining "%s".\n', displayName); end
        results(tt).operation = 'obtain';
        obtainPath = strategy.toolboxPath(obtainRoot, record);
        [results(tt).command, results(tt).status, results(tt).message] = ...
            strategy.obtain(record, obtainRoot, obtainPath);
        
    else
        % toolbox is there already -- update it?
        validName = matlab.lang.makeValidName(record.name);
        lastUpdates = getpref('ToolboxToolbox', 'LastUpdates', []);

        if ~strcmp(record.update, 'never') && ismember(prefs.update, {'daily' 'weekly' 'monthly'})
            if isfield(lastUpdates, validName)
                dLastUpdate = lastUpdates.(validName);
                dElapsed = datetime('now') - dLastUpdate;
            else
                % Toolbox was never updated
                dElapsed = duration(Inf, Inf, Inf);
            end

            dThreshold.daily = days(1);
            dThreshold.weekly = days(7);
            dThreshold.monthly = days(31);

            dRemaining = dThreshold.(prefs.update) - dElapsed;
            isRecentEnough = dRemaining > 0;
        else
            isRecentEnough = false;
        end

        if isRecentEnough
            if (prefs.verbose)
                disp("Found " + displayName + " which is recent enough for another " + string(round(dRemaining, "days")) + ", skipping update")
            end

        elseif strcmp(record.update, 'never') || strcmp(prefs.update, 'never')
            if (prefs.verbose) fprintf('Found "%s" and skipping update.\n', displayName); end

        else
            if (prefs.verbose) fprintf('Updating "%s".\n', displayName); end
            if (strcmp(prefs.update,'force'))
                results(tt).operation = 'update_force';
                force = true;
            else
                results(tt).operation = 'update';
                force = false;
            end
            [results(tt).command, results(tt).status, results(tt).message] = ...
                strategy.update(record, updateRoot, updatePath, force);

            lastUpdates.(validName) = datetime('now');
            setpref('ToolboxToolbox', 'LastUpdates', lastUpdates);
        end
    end
end
