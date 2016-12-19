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
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.KeepUnmatched = true;
parser.PartialMatching = false;
parser.addRequired('toolbox', @(val) ischar(val) || isstruct(val));
parser.addParameter('toolboxRoot', tbGetPref('toolboxRoot', fullfile(tbUserFolder(), 'toolboxes')), @ischar);
parser.addParameter('toolboxCommonRoot', tbGetPref('toolboxCommonRoot', '/srv/toolboxes'), @ischar);
parser.addParameter('withSubfolder', true, @islogical);
parser.parse(toolbox, varargin{:});
toolbox = parser.Results.toolbox;
toolboxRoot = tbHomePathToAbsolute(parser.Results.toolboxRoot);
toolboxCommonRoot = tbHomePathToAbsolute(parser.Results.toolboxCommonRoot);
withSubfolder = parser.Results.withSubfolder;

% convert convenient string to general toolbox record
if ischar(toolbox)
    record = tbToolboxRecord(varargin{:}, 'name', toolbox);
else
    record = toolbox;
end
strategy = tbChooseStrategy(record, varargin{:});

% first, look for a shared toolbox
[toolboxPath, displayName] = strategy.toolboxPath(toolboxCommonRoot, record, ...
    'withSubfolder', withSubfolder);
if 7 == exist(toolboxPath, 'dir')
    return;
end

% then look for a regular toolbox
[toolboxPath, displayName] = strategy.toolboxPath(toolboxRoot, record, ...
    'withSubfolder', withSubfolder);
if 7 == exist(toolboxPath, 'dir')
    return;
end

% din't find the toolbox
toolboxPath = '';
displayName = record.name;


