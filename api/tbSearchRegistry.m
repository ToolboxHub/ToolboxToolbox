function configPath = tbSearchRegistry(name, varargin)
% Search a registry for a configuration with the givne name.
%
% configPath = tbFetchRegistry(name) searches the default ToolboxHub
% registry for a configuration file with the given name.  If found, returns
% the full path to the configuration file.  Otherwise returns ''.
%
% tbFetchRegistry( ... 'registry', registry) specify an explicit toolbox
% record which indicates where and how to access the registry.  The default
% is getpref('ToolboxToolbox', 'registry'), or the public registry at
% Toolbox Hub.
%
% tbDeployToolboxes(... 'toolboxRoot', toolboxRoot) specifies the
% toolboxRoot folder where the registry should be located.  The default
% location is getpref('ToolboxToolbox', 'toolboxRoot'), or 'toolboxes' in
% the userpath() folder.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addRequired('name', @ischar);
parser.addParameter('registry', tbGetPref('registry', tbDefaultRegistry()), @(c) isempty(c) || isstruct(c));
parser.addParameter('toolboxRoot', tbGetPref('toolboxRoot', fullfile(tbUserFolder(), 'toolboxes')), @ischar);
parser.parse(name, varargin{:});
name = parser.Results.name;
registry = parser.Results.registry;
toolboxRoot = tbHomePathToAbsolute(parser.Results.toolboxRoot);

%% Locate the folder that contains the registry.
strategy = tbChooseStrategy(registry);
registryPath = strategy.toolboxPath(toolboxRoot, registry, 'withSubfolder', true);

%% Check for the named configuration.
registryContents = dir(registryPath);
configFiles = {registryContents.name};
configIndex = find(strcmpi(configFiles, [name '.json']), 1, 'first');
if isempty(configIndex)
    configPath = '';
else
    configPath = fullfile(registryPath, configFiles{configIndex});
end
