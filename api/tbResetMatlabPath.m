function [newPath, oldPath] = tbResetMatlabPath(varargin)
% Set the Matlab path to a minimal, consistent state.
%
% [newPath, oldPath] = tbResetMatlabPath() sets the Matlab path to the
% default path for the Toolbox Toolbox.  This path includes the user path,
% all the Matlab installed toolboxes, the Toolbox Toolbox itself, and no
% other folders.  It returns the new value of the path, and the old value
% before the reset.
%
% tbResetMatlabPath( ... 'withInstalled', withInstalled) specify whether to
% include installed Matlab toolboxes on the path.  The default is true,
% include all the installed toolboxes.
%
% tbResetMatlabPath( ... 'withSelf', withSelf) specify whether to
% include the Toolbos Toolbox itself on the path.  The default is true,
% include the Toolbox Toolbox (as determined by the location of this file).
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addParameter('withInstalled', true, @islogical);
parser.addParameter('withSelf', true, @islogical);
parser.parse(varargin{:});
withInstalled = parser.Results.withInstalled;
withSelf = parser.Results.withSelf;

oldPath = path();

%% Start with Matlab's consistent "factory" path.
fprintf('Resetting Matlab path.\n');
restoredefaultpath();

%% Add the ToolboxToolbox itself?
if withSelf
    % assume this function is located in ToolboxToolbox/api
    pathHere = fileparts(mfilename('fullpath'));
    pathToToolbox = fileparts(pathHere);
    selfPath = genpath(pathToToolbox);
    addpath(selfPath, '-end');
    
    % clean up folders like '.git'
    path(tbCleanPath(path()));
end

%% Detect and Remove Extra Installed Toolboxes?
if ~withInstalled
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
