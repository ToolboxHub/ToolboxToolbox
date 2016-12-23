function [isOnline, result] = tbCheckInternet(varargin)
% Check with the operating system whether the Intenet is reachable.
%
% The idea is to check for Internet connectivity with a simple command that
% "fails fast".  And use failure information to avoid calling other
% functions that might take a long, annoying time to fail.
%
% isOnline = tbCheckInternet() checks whether the Internet is reachable
% using a "ping" command that times out after 2 seconds.  Returns true
% if the Internet was reachable.  Also returns the string result of the
% system() command that was used to check for connectivity.
%
% This function uses ToolboxToolbox shared parameters and preferences.  See
% tbParsePrefs().
%
% 2016 benjamin.heasly@gmail.com

[prefs, others] = tbParsePrefs(varargin{:});

% caller wants to skip the check?
if isempty(prefs.checkInternetCommand)
    fprintf('Skipping internet check.\n');
    isOnline = true;
    result = 'skipping internet check';
    return;
end

% are we online?
[status, result, fullCommand] = tbSystem(prefs.checkInternetCommand, others);
strtrim(result);
isOnline = status == 0;

if ~isOnline
    fprintf('Could not reach the internet.\n');
    fprintf('  command: %s\n', fullCommand);
    fprintf('  message: %s\n', result);
    fprintf('You can skip this internet check if you want.  Either:\n');
    fprintf(' - choose an empty ''checkInternetCommand'' in your startup.m, and re-run startup\n');
    fprintf(' - call functions with the ''checkInternetCommand'' parameter set to empty.  For example:\n');
    fprintf('     tbUse( ... ''checkInternetCommand'', '''')\n');
    fprintf('     tbDeployToolboxes( ... ''checkInternetCommand'', '''')\n');
end

% if not, do we throw an error?
assert(~prefs.asAssertion || isOnline, 'tbCheckInternet:internetUnreachable', result);
