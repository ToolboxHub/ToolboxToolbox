function oldPath = tbAddToPath(rootFolder, varargin)
% Add a folder and subfolders to the Matlab path.
%
% toolboxPath = tbAddToPath(rootFolder) adds the given rootFolder and its
% subfolders to the Matlab path and cleans up unnecessary folders like .git
% and .svn.
%
% tbAddToPath(... 'pathPlacement', pathPlacement) specifies whether to
% 'append' or 'prepend' new path entries to the Matlab path.  The default
% is to 'append'.
%
% Returns the old value of the Matlab path.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addRequired('rootFolder', @ischar);
parser.addParameter('pathPlacement', 'append', @ischar);
parser.parse(rootFolder, varargin{:});
rootFolder = tbHomePathToAbsolute(parser.Results.rootFolder);
pathPlacement = parser.Results.pathPlacement;

if strcmp('none', pathPlacement)
    % skip path generation, report current path
    oldPath = path();
    return;
end

% all subfolders of given toolboxPath, except cruft like .git
allFolders = genpath(rootFolder);
cleanFolders = tbCleanPath(allFolders);

% prepend or append to existing Matlab path?
switch pathPlacement
    case 'prepend'
        oldPath = addpath(cleanFolders, '-begin');
    case 'append'
        oldPath = addpath(cleanFolders, '-end');
    otherwise
        % default is append
        oldPath = addpath(cleanFolders, '-end');
end
