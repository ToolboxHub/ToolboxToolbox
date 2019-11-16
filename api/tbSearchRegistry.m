function configPath = tbSearchRegistry(name, persistentPrefs, varargin)
% Search a registry for a configuration with the givne name.
%
% configPath = tbFetchRegistry(name) searches the default ToolboxHub
% registry for a configuration file with the given name.  If found, returns
% the full path to the configuration file.  Otherwise returns ''.
%
% This function uses ToolboxToolbox shared parameters and preferences.  See
% tbParsePrefs().
%
% 2016 benjamin.heasly@gmail.com

prefs = tbParsePrefs(persistentPrefs, varargin{:});

parser = inputParser();
parser.addRequired('name', @ischar);
parser.parse(name);
name = parser.Results.name;

%% Locate the folder that contains the registry.
registryBasePath = tbLocateToolbox(prefs.registry, persistentPrefs, prefs);

% only use first registry subfolder, if any
if ischar(prefs.registry.subfolder)
    registryPath = fullfile(registryBasePath, prefs.registry.subfolder);
elseif iscellstr(prefs.registry.subfolder)
    registryPath = fullfile(registryBasePath, prefs.registry.subfolder{1});
else
    registryPath = registryBasePath;
end

%% Check for the named configuration.
canonicalName = regexprep(name, '[\\/]', filesep);
subfolders = fileparts(canonicalName);
folderConfigFile = fullfile(registryPath, subfolders);
registryContents = dir(folderConfigFile);
localConfigFiles = {registryContents.name};
configFiles = cellfun(@(configFile)fullfile(subfolders, configFile), localConfigFiles, 'Uniform', false);

configIndex = find(strcmpi(configFiles, [canonicalName '.json']), 1, 'first');
if isempty(configIndex)
    configPath = '';
else
    configPath = fullfile(registryPath, configFiles{configIndex});
end
