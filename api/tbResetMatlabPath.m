function [newPath, oldPath] = tbResetMatlabPath(varargin)
% Set the Matlab path to a consistent state.
%
% [newPath, oldPath] = tbResetMatlabPath('name', value, ...) sets the
% Matlab path to a consistent state as determined by the given name-value
% pairs.
%
% This function uses ToolboxToolbox shared parameters and preferences.  See
% tbParsePrefs().
%
% tbResetMatlabPath( ... 'reset', reset) specifies a destired state for the
% Matlab path.  The valid values of reset are:
%   - 'as-is' -- Don't alter the current value of the path.  This would be
%   useful when specifying specific folders to 'add' or 'remove', below.
%   - 'full' -- Include the userpath(), all installed Matlab toolboxes,
%   the ToolboxToolbox itself, and no other folders.  This is the default.
%   - 'no-matlab' -- Like 'full', but does not include any installed
%   Matalb toolboxes.
%   - 'no-self' -- Like 'full', but does not include the ToolboxToolbox
%   itself.
%   - 'bare' -- Include only the userpath() and bare essentials for Matlab
%   to function.
% The default is 'as-is'.
%
% tbResetMatlabPath( ... 'remove', remove) specifies folders to remove from
% to the Matlab path, after setting the path to the given reset.  Valid
% values for remove are:
%   - 'self' -- Remove the ToolboxToolbox itself from the path.
%   - 'matlab' -- Remove all installed Matlab toolboxes from the path.
% The default is '', don't remove any extra entries.
%
% tbResetMatlabPath( ... 'add', add) specifies folders to add to the Matlab
% path, after setting the path to the given reset.  Valid values for add
% are:
%   - 'self' -- Append the ToolboxToolbox itself to the path.
%   - 'matlab' -- Append all installed Matlab toolboxes to the path.
% The default is '', don't add any extra entries.
%
% 2016 benjamin.heasly@gmail.com

persistentPrefs = tbGetPersistentPrefs;

if 1 == nargin() && ischar(varargin{1})
    % support legacy syntax: tbParsePrefs(reset)
    prefs = tbParsePrefs(persistentPrefs, 'reset', varargin{1});
else
    prefs = tbParsePrefs(persistentPrefs, varargin{:});
end


oldPath = path();

% convert arguments to some to-do items.
factoryReset = ~strcmp(prefs.reset, 'as-is');
removeSelf = strcmp(prefs.reset, 'no-self') ...
    || strcmp(prefs.reset, 'bare') ...
    || strcmp(prefs.remove, 'self');
removeMatlab = strcmp(prefs.reset, 'no-matlab') ...
    || strcmp(prefs.reset, 'bare') ...
    || strcmp(prefs.remove, 'matlab');
addMatlab = strcmp(prefs.add, 'matlab');


%% Start with Matlab's consistent "factory" path.
if factoryReset
    tbDeployedToolboxes({}, 'reset');
    
    % This was an attempt to prevent barfing because there
    % are java objects hanging around somewhere.  Might not
    % be sufficient. But it also clears the preferences, becasue
    % these are stored in a persistent variable in a function that
    % gets cleared. This is dangerous territory.  There might be a way to
    % do the clear and keep things working, but for now I am backing off.
    % clear functions
    
    wid = 'MATLAB:dispatcher:pathWarning';
    oldWarningState = warning('query', wid);
    warning('off', wid);
    
    % This is an attempt to unstall added on toolboxes.
    %
    % This should come before the restoredefaultpath() call,
    % to avoid an error that the toolbox being uninstalled is not on
    % the path. 
    %
    % This also seems to cause trouble under Windows if executed before
    % Matlab has fully woken up, so I put a try/catch around it to see if
    % that fixes the issue.
    try
        toolboxes = matlab.addons.toolbox.installedToolboxes;
    catch
        toolboxes = [];
    end
    for tt = 1:length(toolboxes)
       if (prefs.verbose) fprintf('Uninstalling mltbx %s\n',toolboxes(tt).Name); end
       matlab.addons.toolbox.uninstallToolbox(toolboxes(tt));
    end
    
    if (prefs.verbose) fprintf('Resetting path to factory state.\n'); end
    restoredefaultpath();
    
    % Clear dynamic java class path
    p = javaclasspath;
    for ii = 1:length(p)
        if (prefs.verbose) fprintf('Removing %s from dynamic java path\n',p{ii}); end
        javarmpath(p{ii});
    end
    
    warning(oldWarningState.state, wid);
end


%% Always add self, so we can use utilities during this funciton call.
pathHere = fileparts(mfilename('fullpath'));
selfRoot = fileparts(pathHere);
selfPath = genpath(selfRoot);
appendPath('ToolboxToolbox', selfRoot, selfPath, prefs);
path(tbCleanPath(path()));

%% Add or remobe installed Toolboxes.
if removeMatlab
    S = warning('off','MATLAB:dispatcher:pathWarning');
    installedNames = TbInstalledStrategy.installedToolboxNames();
    warning(S);
    for ii = 1:numel(installedNames)
        name = installedNames{ii};
        toolboxRoot = toolboxdir(name);
        toolboxPath = TbInstalledStrategy.factoryPathMatches(toolboxRoot);
        removePath(name, toolboxRoot, toolboxPath, prefs);
    end
end

if addMatlab
    installedNames = TbInstalledStrategy.installedToolboxNames();
    for ii = 1:numel(installedNames)
        name = installedNames{ii};
        toolboxRoot = toolboxdir(name);
        toolboxPath = TbInstalledStrategy.factoryPathMatches(toolboxRoot);
        appendPath(name, toolboxRoot, toolboxPath, prefs);
    end
end

%% Remove self, now that we're done.
if removeSelf
    pathHere = fileparts(mfilename('fullpath'));
    selfRoot = fileparts(pathHere);
    selfPath = genpath(selfRoot);
    removePath('ToolboxToolbox', selfRoot, selfPath, prefs);
end

newPath = path();


%% Append to the Matlab path.
function appendPath(name, pathRoot, pathToAdd, prefs)
wid = 'MATLAB:dispatcher:pathWarning';
oldWarningState = warning('query', wid);
warning('off', wid);

if (prefs.verbose) fprintf('Adding "%s" to path at "%s".\n', name, pathRoot); end
addpath(pathToAdd, '-end');

warning(oldWarningState.state, wid);


%% Remove from the Matlab path.
function removePath(name, pathRoot, pathToRemove,prefs)
wid = 'MATLAB:rmpath:DirNotFound';
oldWarningState = warning('query', wid);
warning('off', wid);

if (prefs.verbose) fprintf('Removing "%s" from path at "%s".\n', name, pathRoot); end
rmpath(pathToRemove);

warning(oldWarningState.state, wid);
