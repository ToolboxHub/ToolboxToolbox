function [toolboxPath, displayName] = tbToolboxPath(toolboxRoot, record)
% Build a consistent toolbox path based on the root and a toolbox record.
%
% toolboxPath = tbToolboxPath(toolboxRoot, record) builds a
% consistently-formatted toolbox path which incorporates the given
% toolboxRoot folder and the name and flavor of the given toolbox record.
%
% Returns an absolute path where the toolbox is located.  Also returns a
% part of the path which would make for a handy display name.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('toolboxRoot', @ischar);
parser.addRequired('record', @isstruct);
parser.parse(toolboxRoot, record);
toolboxRoot = tbHomePathToAbsolute(parser.Results.toolboxRoot);
record = parser.Results.record;


%% Choose folder name for the toolbox.
% basic folder name for toolbox with no special flavor
toolboxFolder = record.name;

% append flavor as "name_flavor"
%   don't use name/flavor -- don't want to nest flavors inside basic
if ~isempty(record.flavor)
    toolboxFolder = [toolboxFolder '_' record.flavor];
end
displayName = toolboxFolder;


%% Choose root folder to contain the toolbox.
if isempty(record.toolboxRoot)
    % put this toolbox with all the other toolboxes
    pathRoot = toolboxRoot;
else
    % put this toolbox in its own special place
    pathRoot = tbHomePathToAbsolute(record.toolboxRoot);
end

% return a full path
assert(~isequal(record.name, 'ToolboxRegistry') || isfield(record, 'toolboxSubfolder'), ...
    'tbToolboxPath:OldToolboxRegistry', ...
    'Your toolbox registry record (most likely from getpref(''ToolboxToolbox'', ''registry'') has an old format. Please re-run the setup')
toolboxPath = fullfile(pathRoot, record.toolboxSubfolder, toolboxFolder);
