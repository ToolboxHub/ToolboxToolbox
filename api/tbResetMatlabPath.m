function [newPath, oldPath] = tbResetMatlabPath(flavor, varargin)
% Set the Matlab path to a consistent state.
%
% [newPath, oldPath] = tbResetMatlabPath(flavor) sets the Matlab path to
% a consistent state, as specified by the given flavor.  The flavor must be
% one of the following:
%   - 'full' -- Include the userpath(), all installed Matlab toolboxes,
%   the ToolboxToolbox itself, and no other folders.  This is the default.
%   - 'no-matlab' -- Like 'full', but does not include any installed
%   Matalb toolboxes.
%   - 'no-self' -- Like 'full', but does not include the ToolboxToolbox
%   itself.
%   - 'bare' -- Include only the userpath() and bare essentials for Matlab
%   to function.
%   - 'as-is' -- Don't alter the current value of the path.  This would be
%   useful when specifying specific folders to 'add' or 'remove', below.
%
% tbResetMatlabPath( ... 'remove', remove) specifies folders to remove from
% to the Matlab path, after setting the path to the given flavor.  Valid
% values for remove are:
%   - 'self' -- Remove the ToolboxToolbox itself from the path.
%   - 'matlab' -- Remove all installed Matlab toolboxes from the path.
%
% tbResetMatlabPath( ... 'add', add) specifies folders to add to the Matlab
% path, after setting the path to the given flavor.  Valid values for add
% are:
%   - 'self' -- Append the ToolboxToolbox itself to the path.
%   - 'matlab' -- Append all installed Matlab toolboxes to the path.
%
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addRequired('flavor', @(f) any(strcmp(f, {'full', 'no-matlab', 'no-self', 'bare', 'as-is'})));
parser.addParameter('add', '', @ischar);
parser.addParameter('remove', '', @ischar);
parser.parse(flavor, varargin{:});
flavor = parser.Results.flavor;
add = parser.Results.add;
remove = parser.Results.remove;

oldPath = path();

% convert arguments to some to-do items.
factoryReset = ~strcmp(flavor, 'as-is');
removeSelf = strcmp(flavor, 'no-self') || strcmp(flavor, 'bare') || strcmp(remove, 'self');
removeMatlab = strcmp(flavor, 'no-matlab') || strcmp(flavor, 'bare') || strcmp(remove, 'matlab');
addMatlab = strcmp(add, 'matlab');


%% Start with Matlab's consistent "factory" path.
if factoryReset
    wid = 'MATLAB:dispatcher:pathWarning';
    oldWarningState = warning('query', wid);
    warning('off', wid);
    
    fprintf('Resetting path to factory state.\n');
    restoredefaultpath();
    
    warning(oldWarningState.state, wid);
end


%% Always add self, so we can use utilities during this funciton call.
pathHere = fileparts(mfilename('fullpath'));
selfRoot = fileparts(pathHere);
selfPath = genpath(selfRoot);
appendPath('ToolboxToolbox', selfRoot, selfPath);
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
        removePath(name, toolboxRoot, toolboxPath);
    end
end

if addMatlab
    installedNames = TbInstalledStrategy.installedToolboxNames();
    for ii = 1:numel(installedNames)
        name = installedNames{ii};
        toolboxRoot = toolboxdir(name);
        toolboxPath = TbInstalledStrategy.factoryPathMatches(toolboxRoot);
        appendPath(name, toolboxRoot, toolboxPath);
    end
end

%% Remove self, now that we're done.
if removeSelf
    pathHere = fileparts(mfilename('fullpath'));
    selfRoot = fileparts(pathHere);
    selfPath = genpath(selfRoot);
    removePath('ToolboxToolbox', selfRoot, selfPath);
end

newPath = path();


%% Append to the Matlab path.
function appendPath(name, pathRoot, pathToAdd)
wid = 'MATLAB:dispatcher:pathWarning';
oldWarningState = warning('query', wid);
warning('off', wid);

fprintf('Adding "%s" to path at "%s".\n', name, pathRoot);
addpath(pathToAdd, '-end');

warning(oldWarningState.state, wid);


%% Remove from the Matlab path.
function removePath(name, pathRoot, pathToRemove)
wid = 'MATLAB:rmpath:DirNotFound';
oldWarningState = warning('query', wid);
warning('off', wid);

fprintf('Removing "%s" from path at "%s".\n', name, pathRoot);
rmpath(pathToRemove);

warning(oldWarningState.state, wid);
