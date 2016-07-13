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
% tbSetToolboxPath(... 'restorePath', restorePath) specifies whether to
% restore the default Matlab path before setting up the toolbox path.  The
% default is false, just append to the existing path.
%
% Returns the parent folder from which the path was set.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addParameter('toolboxPath', pwd(), @ischar);
parser.addParameter('restorePath', false, @islogical);
parser.parse(varargin{:});
toolboxPath = tbHomePathToAbsolute(parser.Results.toolboxPath);
restorePath = parser.Results.restorePath;

%% Start fresh?
if restorePath
    tbResetMatlabPath();
end

%% Compute a new path.
toolboxPath = genpath(toolboxPath);

%% Put the new path in place.
cleanPath = tbCleanPath(toolboxPath);
addpath(cleanPath);
