function registry = tbDefaultRegistry()
% Get a record describing the default shared toolbox registry.
%
% This function returns a toolbox record that describes the public
% ToolboxHub registry of shared toolbox configurations.  This is a
% hard-coded default intended to provide reasonable, non-surprising
% behavior.
%
% In general, users may use other registries by defining a Matlab
% preference with setpref('ToolboxToolbox', 'registry'), or by passing a
% value for the 'registry' parameter of tbFetchRegistry().
%
% 2016 benjamin.heasly@gmail.com

registry = tbToolboxRecord( ...
    'name', 'ToolboxRegistry', ...
    'type', 'git', ...
    'subfolder', 'configurations', ...
    'url', 'https://github.com/ToolboxHub/ToolboxRegistry.git');
