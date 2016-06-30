function toolboxPath = tbSetToolboxPath(varargin)
% Set up the Matlab path for the system's toolbox folder.
%
% The idea is to run this script whenever you need to bring your Matlab
% path to a known state.  For example, this might be tue at the top of a
% Jupyter notebook or automated test suite.  It expects toolboxes to have
% been installed by you or an administrator in an agreed-upon folder, like
% '/usr/local/MATLAB/toolboxes', '~/toolboxes', or similar.
%
% toolboxPath = tbSetToolboxPath() sets the Matlab path for the default
% toolbox folder and its subfolders and cleans up path cruft like hidden
% folders used by Git and Svn.
%
% tbSetToolboxPath(... 'toolboxPath', toolboxPath) specifies the
% toolboxPath folder to set the path for.  The default is '~/toolboxes/'.
%
% tbSetToolboxPath(... 'restorePath', restorePath) specifies whether to
% restore the default Matlab path before setting up the toolbox path.  The
% default is false, just append to the existing path.
%
% Returns the toolboxPath from which the path was set.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addParameter('toolboxPath', '~/toolboxes', @ischar);
parser.addParameter('restorePath', false, @islogical);
parser.parse(varargin{:});
toolboxPath = tbHomePathToAbsolute(parser.Results.toolboxPath);
restorePath = parser.Results.restorePath;

%% Start fresh?
if restorePath
    fprintf('Restoring Matlab default path.\n');
    tbResetMatlabPath();
end

fprintf('Adding toolbox path "%s"\n', toolboxPath);

%% Compute a new path.
toolboxPath = genpath(toolboxPath);

%% Put the new path in place.
cleanPath = tbCleanPath(toolboxPath);
addpath(cleanPath);
