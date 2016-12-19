function toolboxPath = tbAddToolboxPath(varargin)
% Add a toolbox to the Matlab path.
%
% toolboxPath = tbAddToolboxPath() adds the current folder (pwd()) and its
% subfolders to the Matlab path and cleans up unnecessary folders like .git
% and .svn.
%
% tbAddToolboxPath(... 'toolboxPath', toolboxPath) specifies the
% toolboxPath folder to set the path for.  The default is pwd().
%
% tbAddToolboxPath(... 'pathPlacement', pathPlacement) specifies whether to
% 'append' or 'prepend' new path entries to the Matlab path.  The default
% is to 'append'.
%
% Returns the parent folder from which the path was set.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.KeepUnmatched = true;
parser.addParameter('toolboxPath', pwd(), @ischar);
parser.addParameter('pathPlacement', 'append', @ischar);
parser.parse(varargin{:});
toolboxPath = tbHomePathToAbsolute(parser.Results.toolboxPath);
pathPlacement = parser.Results.pathPlacement;

% all subfolders of given toolboxPath, except cruft like .git
toolboxAllFolders = genpath(toolboxPath);
cleanPath = tbCleanPath(toolboxAllFolders);

% prepend or append to existing Matlab path
if strcmp(pathPlacement, 'prepend')
    addpath(cleanPath, '-begin');
else
    addpath(cleanPath, '-end');
end
