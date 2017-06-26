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
% Using 'prependrootonly' or 'appendrootonly' causes the routine not to
% include subfolders of passed root folder.
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

% Do the right thing based on pathPlacement
switch pathPlacement
    case 'none'
        oldPath = path();
    case 'prependrootonly'
        allFolders = rootFolder;
        cleanFolders = tbCleanPath(allFolders);
        oldPath = addpath(cleanFolders, '-begin');
    case 'prepend'
        % all subfolders of given toolboxPath, except cruft like .git
        allFolders = genpath(rootFolder);
        cleanFolders = tbCleanPath(allFolders); 
        oldPath = addpath(cleanFolders, '-begin');
    case 'appendrootonly'
        allFolders = rootFolder;
        cleanFolders = tbCleanPath(allFolders);
        oldPath = addpath(cleanFolders, '-end');
    case 'append'
        % all subfolders of given toolboxPath, except cruft like .git
        allFolders = genpath(rootFolder);
        cleanFolders = tbCleanPath(allFolders);       
        oldPath = addpath(cleanFolders, '-end');
    otherwise
        error('Illegal string provided for pathPlacement');
end
