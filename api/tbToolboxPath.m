function toolboxPath = tbToolboxPath(toolboxRoot, record, varargin)
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
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addRequired('toolboxRoot', @ischar);
parser.addRequired('record', @isstruct);
parser.addParameter('withSubfolder', false, @islogical);
parser.parse(toolboxRoot, record, varargin{:});
toolboxRoot = parser.Results.toolboxRoot;
record = parser.Results.record;
withSubfolder = parser.Results.withSubfolder;

% basic path to toolbox with no special flavor
toolboxPath = fullfile(toolboxRoot, record.name);

% append flavor as "name-flavor"
%   don't use name/flavor -- don't want to nest flavors inside basic
if ~isempty(record.flavor)
    toolboxPath = [toolboxPath '-' record.flavor];
end

if withSubfolder
    toolboxPath = fullfile(toolboxPath, record.subfolder);
end
