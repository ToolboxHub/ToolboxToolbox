function [toolboxPath, displayName] = tbLocateToolbox(toolbox, varargin)
% Locate the folder that contains the given toolbox.
%
% toolboxPath = tbLocateToolbox(name) locates the toolbox with the given
% string name and returns the path to that toolbox.  This may be a path
% within the configured toolboxRoot, or toolboxCommonRoot.
%
% toolboxPath = tbLocateToolbox(record) locates the toolbox from the given
% record struct, instead of the given string name.
%
% This function uses ToolboxToolbox shared parameters and preferences.  See
% tbParsePrefs().
%
% 2016 benjamin.heasly@gmail.com

[prefs, others] = tbParsePrefs(varargin{:});

parser = inputParser();
parser.addRequired('toolbox', @(val) ischar(val) || isstruct(val));
parser.parse(toolbox);
toolbox = parser.Results.toolbox;

% convert convenient string to general toolbox record
if ischar(toolbox)
    record = tbToolboxRecord(others, 'name', toolbox);
else
    record = toolbox;
end
strategy = tbChooseStrategy(record, prefs);

% first, look for a shared toolbox
[toolboxPath, displayName] = strategy.toolboxPath(prefs.toolboxCommonRoot, record);
if 7 == exist(toolboxPath, 'dir')
    return;
end

% then look for a regular toolbox
[toolboxPath, displayName] = strategy.toolboxPath(prefs.toolboxRoot, record);
if 7 == exist(toolboxPath, 'dir')
    return;
end

% din't find the toolbox
toolboxPath = '';
displayName = record.name;


