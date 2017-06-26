function [projectPath, configPath, projectParent] = tbLocateProject(project, varargin)
% Locate the folder that contains the given project.
%
% projectPath = tbLocateProject(name) locates the project with the given
% string name and returns the path to that project.  This will be a path
% within the configured projectRoot.
%
% projectPath = tbLocateProject(record) locates the project from the given
% record struct, instead of the given string name.
%
% This function uses ToolboxToolbox shared parameters and preferences.  See
% tbParsePrefs().
%
% 2016 benjamin.heasly@gmail.com

[prefs, others] = tbParsePrefs(varargin{:});

parser = inputParser();
parser.addRequired('project', @(val) ischar(val) || isstruct(val));
parser.parse(project);
project = parser.Results.project;

% convert convenient string to general record
if ischar(project)
    record = tbToolboxRecord(others, 'name', project);
else
    record = project;
end

projectPath = '';
projectParent = '';

if (prefs.verbose) fprintf('Locating project "%s" within "%s".\n', record.name, prefs.projectRoot); end

%% Look for config file Foo.json anywhere in the projects folder.
configName = [record.name '.json'];
configPath = findFile(prefs.projectRoot, configName);
if isempty(configPath)
    if (prefs.verbose) fprintf('  Could not find config file named "%s".\n', configName); end
    return;
end


%% Look for project folder Foo that contains Foo.json.
minPathLength = numel(prefs.projectRoot);
[projectParent, folderName] = fileparts(fileparts(configPath));
while numel(projectParent) > minPathLength && ~strcmp(folderName, record.name)
    [projectParent, folderName] = fileparts(projectParent);
end

if strcmp(folderName, record.name)
    projectPath = fullfile(projectParent, folderName);
    if (prefs.verbose) fprintf('  Found at "%s".\n', projectPath); end
else
    if (prefs.verbose)
        fprintf('  Could not find folder "%s" containing config "%s".\n', ...
            record.name, configName);
    end
end


%% Search recursively for a file, by name.
function filePath = findFile(directory, fileName)

dirList = dir(directory);
isDir = [dirList.isdir];

% file match in this dir?
for ff = find(~isDir)
    d = dirList(ff);
    if strcmp(d.name, fileName)
        filePath = fullfile(directory, fileName);
        return;
    end
end

% file match in subdirs?
for dd = find(isDir)
    d = dirList(dd);
    if d.name(1) == '.'
        % ignore special folders
        continue;
    end
    subdirectory = fullfile(directory, d.name);
    filePath = findFile(subdirectory, fileName);
    if ~isempty(filePath)
        return;
    end
end

% never found a match
filePath = '';

