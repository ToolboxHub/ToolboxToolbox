function [toolboxPath, displayName, toolboxRoot] = tbLocateToolbox(toolbox, persistentPrefs, varargin)
% Locate the folder that contains the given toolbox.
%
% toolboxPath = tbLocateToolbox(name) locates the toolbox with the given
% string name and returns the path to that toolbox.  This may be a path
% within the prefs toolboxRoot, or toolboxCommonRoot.
%
% toolboxPath = tbLocateToolbox(record) locates the toolbox from the given
% record struct, instead of the given string name.
%
% This function uses ToolboxToolbox shared parameters and preferences.  See
% tbParsePrefs().
%
% 2016 benjamin.heasly@gmail.com

if nargin == 1
    persistentPrefs = tbGetPersistentPrefs;
end

[prefs, others] = tbParsePrefs(persistentPrefs, varargin{:});

parser = inputParser();
parser.addRequired('toolbox', @(val) ischar(val) || isstruct(val) || isstring(val));
parser.parse(toolbox);
toolbox = parser.Results.toolbox;

if isstring(toolbox)
    toolbox = char(toolbox);
end

% convert convenient string to general toolbox record
if ischar(toolbox)
    record = tbToolboxRecord(others, 'name', toolbox);
else
    record = toolbox;
end
strategy = tbChooseStrategy(record, persistentPrefs, prefs);

% first, look for a toolbox or project in its own, explicit location
if ~isempty(record.toolboxRoot)
    toolboxRoot = record.toolboxRoot;
    [toolboxPath, displayName] = strategy.toolboxPath(toolboxRoot, record);
    if strategy.checkIfPresent(record, toolboxRoot, toolboxPath)
        return;
    end
end

% second, look for a pre-installed toolbox
toolboxRoot = prefs.toolboxCommonRoot;
[toolboxPath, displayName] = strategy.toolboxPath(toolboxRoot, record);
if strategy.checkIfPresent(record, toolboxRoot, toolboxPath)
    return;
end

% last, look for a regular toolbox
toolboxRoot = prefs.toolboxRoot;
[toolboxPath, displayName] = strategy.toolboxPath(toolboxRoot, record);
if strategy.checkIfPresent(record, toolboxRoot, toolboxPath)
    return;
end

% alas, didn't find the toolbox
toolboxPath = '';
displayName = record.name;
toolboxRoot = '';


