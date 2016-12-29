function results = tbUseProject(name, varargin)
% Find an existing project within the projectRoot, and deploy it.
%
% The goal here is to make it a one-liner to deploy a project by name,
% which already exists within the configured projectRoot.
%
% First we locate the project by name.  For a project Foo:
%   - There must be a config file Foo.json.
%   - Foo.json must be inside a folder named Foo (projectRoot/**/Foo/**/Foo.json)
%
% Then we deploy the project and its dependencies, using Foo.json.
%
% This function uses ToolboxToolbox shared parameters and preferences.  See
% tbParsePrefs().
%
% 2016 benjamin.heasly@gmail.com

prefs = tbParsePrefs(varargin{:});

parser = inputParser();
parser.addRequired('name', @ischar);
parser.parse(name);
name = parser.Results.name;

results = [];

%% Locate the project.
[projectPath, configPath, projectParent] = tbLocateProject(name, prefs);
if isempty(projectPath)
    return;
end


%% Deploy the project.
config = tbReadConfig(prefs, 'configPath', configPath);
if isempty(config)
    fprintf('No toolboxes declared in "%s".\n', configPath);
    return;
end

% point the project into its own folder -- ie only try to update it
isProject = strcmp(name, {config.name});
if any(isProject)
    [config(isProject).toolboxRoot] = deal(projectParent);
end

results = tbDeployToolboxes('config', config, prefs);

%% Run the projects's local hook, if it exists
% 
% This needs some tidying and bullet-proofing.
if (prefs.runLocalHooks)
    if (exist(fullfile(prefs.localHookFolder,[name 'LocalHook.m']),'file'))
        fprintf('  Running local hook %s\n',fullfile(prefs.localHookFolder,[name 'LocalHook.m']));
        eval(['run ' fullfile(prefs.localHookFolder,[name 'LocalHook.m'])]);
    elseif (exist(fullfile(prefs.localHookFolder,[name '.m']),'file'))
        fprintf('  Running local hook %s\n',fullfile(prefs.localHookFolder,[name '.m']));
        eval(['run ' fullfile(prefs.localHookFolder,[name 'LocalHook.m'])]);
    end
end



