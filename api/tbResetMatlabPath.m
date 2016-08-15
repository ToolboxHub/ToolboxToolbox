function [newPath, oldPath] = tbResetMatlabPath(varargin)
% Set the Matlab path to a minimal, consistent state.
%
% [newPath, oldPath] = tbResetMatlabPath() sets the Matlab path to the
% default path for the ToolboxToolbox.  This path includes the user path,
% all the Matlab installed toolboxes, the ToolboxToolbox itself, and no
% other folders.  It returns the new value of the path, and the old value
% before the reset.
%
% tbResetMatlabPath(... 'reset', reset) specifies which parts of the
% Matlab path to reset / clear out:
%   - 'none' -- don't clear out anything
%   - 'local' -- clear out toolboxes that are not part of matlab (the default)
%   - 'matlab' -- clear out installed Matlab toolboxes
%   - 'all' -- clear out user toolboxes and installed Matlab toolboxes
%
% tbResetMatlabPath( ... 'withSelf', withSelf) specify whether to
% include the ToolboxToolbox itself on the path.  The default is true,
% include the ToolboxToolbox as determined by the location of this file.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addParameter('reset', 'local', @ischar);
parser.addParameter('withSelf', true, @islogical);
parser.parse(varargin{:});
reset = parser.Results.reset;
withSelf = parser.Results.withSelf;

oldPath = path();

resetLocalToolboxes = any(strcmp(reset, {'all', 'local'}));
resetMatlabToolboxes = any(strcmp(reset, {'all', 'matlab'}));

%% Start with Matlab's consistent "factory" path.
if resetLocalToolboxes
    fprintf('Resetting path for local toolboxes.\n');
    
    wid = 'MATLAB:dispatcher:pathWarning';
    oldWarningState = warning('query', wid);
    warning('off', wid);
    restoredefaultpath();
    warning(oldWarningState.state, wid);
end

%% Add the ToolboxToolbox itself?
if withSelf
    % assume this function is located in ToolboxToolbox/api
    pathHere = fileparts(mfilename('fullpath'));
    toolboxToolboxPath = fileparts(pathHere);
    
    fprintf('Adding ToolboxToolbox to path at "%s".\n', toolboxToolboxPath);
    
    selfPath = genpath(toolboxToolboxPath);
    addpath(selfPath, '-end');
    
    % clean up folders like '.git'
    path(tbCleanPath(path()));
end

%% Detect and Remove Extra Installed Toolboxes?
if resetMatlabToolboxes
    fprintf('Resetting path for installed Matlab toolboxes.\n');
    
    % look in matlabroot()/toolboxes for built-in and installed toolboxes
    toolboxFolders = dir(toolboxdir(''));
    nToolboxes = numel(toolboxFolders);
    toRemove = false(1, nToolboxes);
    for tt = 1:nToolboxes
        toolboxName = toolboxFolders(tt).name;
        
        % skip folders that can't be considered "installed" toolboxes
        if any(strcmp(toolboxName, {'.', '..', 'matlab'}))
            continue;
        end
        
        % detect installed toolboxes as those that have version info
        versionInfo = ver(toolboxName);
        toRemove(tt) = ~isempty(versionInfo);
    end
    
    % remove installed toolboxes from the path
    wid = 'MATLAB:rmpath:DirNotFound';
    oldWarningState = warning('query', wid);
    warning('off', wid);
    removeFolders = {toolboxFolders(toRemove).name};
    nRemoveFolders = numel(removeFolders);
    for tt = 1:nRemoveFolders
        removePath = toolboxdir(removeFolders{tt});
        rmpath(genpath(removePath));
    end
    warning(oldWarningState.state, wid);
end

newPath = path();
