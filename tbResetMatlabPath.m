function [oldPath, newPath] = tbResetMatlabPath(varargin)
% Set the Matlab path to a minimal, consistent state.
%
% [oldPath, newPath] = tbResetMatlabPath() sets the Matlab path to the
% default path for the Toolbox Toolbox.  This path includes all the Matlab
% built-in toolboxes, as well as the Toolbox Toolbox itself.  Returns the
% old value of the Matlab path (as from path()) as well as the new value
% set by this function.
%
% tbResetMatlabPath( ... 'withBuiltIn', withBuiltIn) specify whether to
% include the Matlab build-in toolboxes on the path.  The default is true,
% include all the built-ins.
%
% tbResetMatlabPath( ... 'withSelf', withSelf) specify whether to
% include the Toolbos Toolbox itself on the path.  The default is true,
% include the Toolbox Toolbox (as determined by the location of this file).
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addParameter('withBuiltIn', true, @islogical);
parser.addParameter('withSelf', true, @islogical);
parser.parse(varargin{:});
withBuiltIn = parser.Results.withBuiltIn;
withSelf = parser.Results.withSelf;

oldPath = path();

%% Start with or without this Toolbox Toolbox?
if withSelf
    pathHere = fileparts(mfilename('fullpath'));
    selfPath = genpath(pathHere);
else
    selfPath = '';
end

%% Start with or without built-in Matlab toolboxes?
if withBuiltIn
    restoredefaultpath();
    builtInPath = path();
else
    builtInPath = '';
end

%% Apply the new path.
newPath = [selfPath ':' builtInPath];
path(newPath);
