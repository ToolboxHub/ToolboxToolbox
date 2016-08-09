%% Demonstrate how to deploy only specific Matlab toolboxes.
%
% This demo uses the ToolboxToolbox "installed" record type to select one
% specific matlab toolbox and add it to the Matlab path.  Other installed
% toolboxes will be excluded from the Matlab path.
%
% This works in two steps.  First, we can kick all installed Matlab
% toolboxes off the Matlab path.  Then, we can deploy specific Matlab
% toolboxes by name, and only these ones will be on the path.
%
% 2016 benjamin.heasly@gmail.com

clear;

%% What Matlab toolboxes do we have installled?
fprintf('The following Matlab toolboxes are installed:\n');
ver();
fprintf('\n');

%% Choose a toolbox and verify we can find one of its functions.
toolboxName = 'images';
functionName = 'imageinfo';

toolboxFolder = toolboxdir(toolboxName);
fprintf('Found "%s" toolbox at "%s".\n', toolboxName, toolboxFolder);

functionPath = which(functionName);
fprintf('Found "%s" function at "%s".\n', functionName, functionPath);
fprintf('\n');


%% Show that we can kick installed toolboxes off the path.
tbResetMatlabPath('reset', 'all');

functionPath = which(functionName);
fprintf('Looked for "%s" function, got path "%s".\n', functionName, functionPath);
fprintf('\n');

%% Bring back our specific toolbox, by name.
record = tbToolboxRecord( ...
    'type', 'installed', ...
    'name', 'images');
tbDeployToolboxes( ...
    'config', record, ...
    'reset', 'all');


functionPath = which(functionName);
fprintf('Found "%s" function at "%s".\n', functionName, functionPath);
fprintf('\n');

