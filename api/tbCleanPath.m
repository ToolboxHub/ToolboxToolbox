function cleanPath = tbCleanPath(originalPath)
% Clean out useless path entries, for example .git hidden folders.
%
% cleanPath = tbCleanPath(originalPath) takes the given originalPath path
% string and strips out path entries that we probably don't want, like
% hidden ".git" folders used by the Git tool, and others.  Returns a new
% path string without these entries.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addRequired('originalPath', @ischar);
parser.parse(originalPath);
originalPath = parser.Results.originalPath;

if isempty(originalPath)
    cleanPath = originalPath;
    return;
end

% break the path into separate entries
scanResults = textscan(originalPath, '%s', 'delimiter', pathsep());
pathElements = scanResults{1};

% locate svn, git, mercurial entries
isCleanFun = @(s) isempty(regexp(s, '\.svn|\.git|\.hg', 'once'));
isClean = cellfun(isCleanFun, pathElements);

% print a new, clean path
cleanElements = pathElements(isClean);
cleanPath = sprintf(['%s' pathsep()], cleanElements{:});
