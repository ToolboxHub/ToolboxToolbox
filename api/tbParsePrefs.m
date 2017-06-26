function [prefs, others] = tbParsePrefs(varargin)
% Parse out ToolboxToolbox shared parameters and preferences.
%
% The idea here is to have one place where we parse parameters and check
% preferences that are shared among multiple ToolboxToolbox functions.
% This should avoid code duplication and inconsistencies.
%
% This should also make it convenient to override any of the ToolboxToolbox
% preferences that were chosen in startup.m.  Those values will be
% used as defaults, but can be overriden if new values are passed to this
% function.
%
% [prefs, others] = tbParsePrefs('name', value, ...) parses the given
% name-value pairs and supplements them with ToolboxToolbox preferences
% that were established in startup.m.  Returns a struct of shared
% preferences that cab be used by several ToolboxToolbox functions.  Also
% returns a struct of other name-value pairs that were not recognized as
% shared preferences.  These may be useful to the caller.
%
% Here are the ToolboxToolbox shared preference names and interpretations:
%
%   - 'toolboxRoot' -- where to put/look for normal toolboxes
%   - 'toolboxCommonRoot' -- where to look for "pre-installed" toolboxes
%   - 'projectRoot' -- where to look for non-toolbox projects
%   - 'localHookFolder' -- where to look for local hooks for each toolbox
%   - 'checkInternetCommand' -- system() command to check for connectivity
%   - 'registry' -- toolbox record for which ToolboxRegistry to use
%   - 'configPath' -- where to read/write JSON toolbox configuration
%   - 'asAssertion' -- throw an error if the function fails?
%   - 'runLocalHooks' -- invoke local hooks during deployment?
%   - 'addToPath' -- add toolboxes to the Matlab path during deployment?
%   - 'reset' -- how to tbResetMatlabPath() before deployment
%   - 'add' -- how to tbResetMatlabPath() before deployment
%   - 'remove' -- how to tbResetMatlabPath() before deployment
%   - 'online' -- whether or not the Internet is reachable
%   - 'verbose' -- print out or shut up?
%
% 2016-2017 benjamin.heasly@gmail.com

parser = inputParser();
parser.KeepUnmatched = true;
parser.PartialMatching = false;
parser.addParameter('toolboxRoot', tbGetPref('toolboxRoot', fullfile(tbUserFolder(), 'toolboxes')), @ischar);
parser.addParameter('toolboxCommonRoot', tbGetPref('toolboxCommonRoot', '/srv/toolboxes'), @ischar);
parser.addParameter('projectRoot', tbGetPref('projectRoot', fullfile(tbUserFolder(), 'projects')), @ischar);
parser.addParameter('localHookFolder', tbGetPref('localHookFolder', fullfile(tbUserFolder(), 'localHookFolder')), @ischar);
parser.addParameter('checkInternetCommand', tbGetPref('checkInternetCommand', ''), @ischar);
parser.addParameter('registry', tbGetPref('registry', tbDefaultRegistry()), @(c) isempty(c) || isstruct(c));
parser.addParameter('configPath', tbGetPref('configPath', fullfile(tbUserFolder(), 'toolbox_config.json')), @ischar);
parser.addParameter('asAssertion', false, @islogical);
parser.addParameter('runLocalHooks', true, @islogical);
parser.addParameter('addToPath', true, @islogical);
parser.addParameter('reset', 'as-is', @(f) any(strcmp(f, {'full', 'no-matlab', 'no-self', 'bare', 'as-is'})));
parser.addParameter('add', '', @ischar);
parser.addParameter('remove', '', @ischar);
parser.addParameter('online', logical([]), @islogical);
parser.addParameter('verbose', true, @islogical);
parser.parse(varargin{:});
prefs = parser.Results;
others = parser.Unmatched;

% if "online" not give explicitly, check for the Internet
if isempty(prefs.online)
    prefs.online = tbCheckInternet(prefs);
end
