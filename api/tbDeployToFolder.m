function results = tbDeployToFolder(rootFolder, varargin)
% Deploy toolboxes to a given rootFolder, instead of toolboxRoot.
%
% This is a convenience wrapper around tbDeployToolboxes().  It deployes
% toolboxes to the given rootFolder, regardless of the currently configured
% toolboxCommonRoot, toolboxRoot, or projectRoot, or any toolboxRoot field
% specified in toolbox records.  This is useful for temporary deployments
% that should be kept separate from regular toolboxes and proects, and
% should be easy to delete.
%
% results = tbDeployToFolder() fetches each toolbox from the default
% toolbox configuration into the given rootFolder and adds each to the
% Matlab path.  Returns a struct of results about what happened for each
% toolbox.
%
% tbDeployToFolder(... 'config', config) deploy the given struct array of
% toolbox records instead of the default toolbox configuration.
%
% This function uses ToolboxToolbox shared parameters and preferences.  See
% tbParsePrefs().
%
% 2017 benjamin.heasly@gmail.com

[prefs, others] = tbParsePrefs(varargin{:});

parser = inputParser();
parser.addRequired('rootFolder', @ischar);
parser.addParameter('config', [], @(c) isempty(c) || isstruct(c));
parser.parse(rootFolder, others);
rootFolder = parser.Results.rootFolder;
config = parser.Results.config;


%% Choose explicit config, or load from file.
if isempty(config) || ~isstruct(config) || ~isfield(config, 'name')
    config = tbReadConfig(prefs);
end

%% Put all toolboxes into the given root folder.
config = tbDealField(config, 'toolboxRoot', rootFolder);
prefs.toolboxCommonRoot = rootFolder;


%% The rest of the deployment is the same as usual.
results = tbDeployToolboxes('config', config, prefs);
