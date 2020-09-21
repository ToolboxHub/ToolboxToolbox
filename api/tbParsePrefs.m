function [prefs, others] = tbParsePrefs(persistentPrefs, varargin)
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
% [prefs, others] = tbParsePrefs(persistentPrefs, 'name', value, ...) parses the given
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
%   - 'toolboxSubfolder' -- which subfolder of <toolboxRoot> to put/look
%                           for normal toolboxes
%   - 'projectRoot' -- where to look for non-toolbox projects
%   - 'localHookFolder' -- where to look for local hooks for each toolbox
%   - 'checkInternetCommand' -- system() command to check for connectivity
%   - 'registry' -- toolbox record for which ToolboxRegistry to use
%   - 'configPath' -- where to read/write JSON toolbox configuration
%   - 'asAssertion' -- throw an error if the function fails?
%   - 'runLocalHooks' -- invoke local hooks during deployment?
%   - 'printLocalHookOutput' -- print anything local hook outputs to command window as it runs?
%   - 'addToPath' -- add toolboxes to the Matlab path during deployment?
%   - 'reset' -- how to tbResetMatlabPath() before deployment
%   - 'add' -- how to tbResetMatlabPath() before deployment
%   - 'remove' -- how to tbResetMatlabPath() before deployment
%   - 'online' -- whether or not the Internet is reachable
%   - 'verbose' -- print out or shut up?
%   - 'checkTbTb' -- whether to check whether TbTb is up to date (logical, default true)
%   - 'updateRegistry' -- whether to update TbRegistry (logical, default true)
%   - 'update' -- whether to update all other toolboxes ('asspecified'/'never')
%                 'asspecified' (default) follows what is specified in the
%                 update field of the toolbox record. 'never' overrides
%                 that field and does not update any of the toolboxes.
%
% 2016-2017 benjamin.heasly@gmail.com

userFolder = tbUserFolder();

parser = inputParser();
parser.KeepUnmatched = true;
parser.PartialMatching = false;
parser.addParameter('toolboxRoot', tbGetPref(persistentPrefs, 'toolboxRoot', fullfile(userFolder, 'toolboxes')), @ischar);
parser.addParameter('toolboxCommonRoot', tbGetPref(persistentPrefs, 'toolboxCommonRoot', '/srv/toolboxes'), @ischar);
parser.addParameter('toolboxSubfolder', '', @ischar);
parser.addParameter('projectRoot', tbGetPref(persistentPrefs, 'projectRoot', fullfile(userFolder, 'projects')), @ischar);
parser.addParameter('localHookFolder', tbGetPref(persistentPrefs, 'localHookFolder', fullfile(userFolder, 'localHookFolder')), @ischar);
parser.addParameter('checkInternetCommand', tbGetPref(persistentPrefs, 'checkInternetCommand', ''), @ischar);
parser.addParameter('registry', tbGetPref(persistentPrefs, 'registry', tbDefaultRegistry()), @(c) isempty(c) || isstruct(c));
parser.addParameter('configPath', tbGetPref(persistentPrefs, 'configPath', fullfile(userFolder, 'toolbox_config.json')), @ischar);
parser.addParameter('asAssertion', false, @islogical);
parser.addParameter('runLocalHooks', true, @islogical);
parser.addParameter('printLocalHookOutput', logical(tbGetPref(persistentPrefs, 'printLocalHookOutput', 0)), @(x) (islogical(x) || ischar(x)));
parser.addParameter('addToPath', true, @islogical);
parser.addParameter('reset', tbGetPref(persistentPrefs, 'reset', 'full'), @(f) any(strcmp(f, {'full', 'no-matlab', 'no-self', 'bare', 'as-is'})));
parser.addParameter('add', '', @ischar);
parser.addParameter('remove', '', @ischar);
parser.addParameter('online', logical([]), @islogical);
parser.addParameter('verbose', tbGetPref(persistentPrefs, 'verbose', true), @islogical);
parser.addParameter('checkTbTb', tbGetPref(persistentPrefs, 'checkTbTb', true), @islogical);
parser.addParameter('updateRegistry', tbGetPref(persistentPrefs, 'updateRegistry', true), @islogical);
parser.addParameter('update', tbGetPref(persistentPrefs, 'update', 'asspecified'), @(f) (isempty(f) | any(strcmp(f, {'asspecified' 'never'}))));
parser.parse(varargin{:});
prefs = parser.Results;
others = parser.Unmatched;

% if "online" not give explicitly, check for the Internet
if isempty(prefs.online)
    prefs.online = tbCheckInternet(persistentPrefs, prefs);
end
