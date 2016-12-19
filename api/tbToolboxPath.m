function [toolboxPath, subfolder] = tbToolboxPath(toolboxRoot, record, varargin)
% Build a consistent toolbox path based on the root and a toolbox record.
%
% toolboxPath = tbToolboxPath(toolboxRoot, record) builds a
% consistently-formatted toolbox path which incorporates the given
% toolboxRoot folder and the name and flavor of the given toolbox record.
%
% tbToolboxPath( ... 'withSubfolder', withSubfolder) specify whether to
% append the given record.subfolder to the toolbox path (true) or not
% (false).  The default is false, omit the subfolder.
%
% Returns an absolute path where the toolbox is located.  Also returns a
% subfolder which is the last part of the absolute path, handy as a display
% name for the toolbox.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('toolboxRoot', @ischar);
parser.addRequired('record', @isstruct);
parser.addParameter('withSubfolder', false, @islogical);
parser.parse(toolboxRoot, record, varargin{:});
toolboxRoot = tbHomePathToAbsolute(parser.Results.toolboxRoot);
record = parser.Results.record;
withSubfolder = parser.Results.withSubfolder;

%% Choose subfolder for the toolbox.
% basic subfolder for toolbox with no special flavor
subfolder = record.name;

% append flavor as "name_flavor"
%   don't use name/flavor -- don't want to nest flavors inside basic
if ~isempty(record.flavor)
    subfolder = [subfolder '_' record.flavor];
end

if withSubfolder
    subfolder = fullfile(subfolder, record.subfolder);
end

%% Choose root folder to contain the subfolder.
if isempty(record.toolboxRoot)
    % put this toolbox with all the other toolboxes
    pathRoot = toolboxRoot;
else
    % put this toolbox in its own special place
    pathRoot = tbHomePathToAbsolute(record.toolboxRoot);
end

% return a full path
toolboxPath = fullfile(pathRoot, subfolder);
