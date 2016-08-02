function toolboxPath = tbSetToolboxPath(varargin)
% Set up the Matlab path for the system's toolbox folder.
%
% The idea is to run this script whenever you need to bring your Matlab
% path to a known state.  For example, when installing toolboxes or running
% automated tests.
%
% toolboxPath = tbSetToolboxPath() sets the Matlab path for the current
% folder (pwd()) and its subfolders and cleans up path cruft like hidden
% folders used by Git and Svn.
%
% tbSetToolboxPath(... 'toolboxPath', toolboxPath) specifies the
% toolboxPath folder to set the path for.  The default is pwd().
%
% tbSetToolboxPath(... 'resetPath', resetPath) specifies whether to
% restore the default Matlab path before setting up the toolbox path.  The
% default is false, just append to the existing path.
%
% tbSetToolboxPath(... 'pathPlacement', pathPlacement) specifies whether to
% 'append' or 'prepend' new path entries to the Matlab path.  The default
% is to 'append'.
%
% Returns the parent folder from which the path was set.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addParameter('toolboxPath', pwd(), @ischar);
parser.addParameter('resetPath', false, @islogical);
parser.addParameter('pathPlacement', 'append', @ischar);
parser.parse(varargin{:});
toolboxPath = tbHomePathToAbsolute(parser.Results.toolboxPath);
resetPath = parser.Results.resetPath;
pathPlacement = parser.Results.pathPlacement;

%% Start fresh?
if resetPath
    tbResetMatlabPath();
end

%% Compute a new path.
toolboxPath = genpath(toolboxPath);

%% Put the new path in place.
cleanPath = tbCleanPath(toolboxPath);
if strcmp(pathPlacement, 'prepend')
    addpath(cleanPath, '-begin');
else
    addpath(cleanPath, '-end');
end
