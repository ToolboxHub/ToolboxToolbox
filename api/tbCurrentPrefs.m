function prefs = tbCurrentPrefs(varargin)
% Set or get the current working ToolboxToolbox preferences.
%
% This function gives a way to share the current, working ToolboxToolbox
% prefs struct between ToolboxToolbox functions and user scripts.   Between
% functions, it is better to pass the prefs struct as an argument.  But
% when calling user-defined scripts, like local hooks, we need this other
% way to communicate the current preferences.
%
% This function uses a persistent variable internally.
%
% tbCurrentPrefs(prefs) sets the current working preferences to the given
% prefs.
%
% prefs = tbCurrentPrefs() gets the current working preferences that were
% set earlier.
%
% 2016-2017 benjamin.heasly@gmail.com

persistent persistentPrefs

if nargin > 0
    % store the given prefs
    persistentPrefs = tbParsePrefs(varargin{:});
end

prefs = persistentPrefs;
