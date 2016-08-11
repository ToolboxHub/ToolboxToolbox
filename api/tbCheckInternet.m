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
% tbCheckInternet( ... 'checkInternetCommand', checkInternetCommand)
% specify the command to pass to system() which will check for Internet
% connectivity.  The default command is getpref('ToolboxToolbox',
% 'checkInternetCommand'), or 'ping -c 1 -t 2 www.google.com'.
%
% tbCheckInternet( ... 'asAssertion', asAssertion) specify whether to treat
% the call to tbCheckInternet() as an assertion.  If asAssertion is true
% and the Internet is not reachable, throws an error with the system()
% command result. Otherwise returns normally.  The default is false, don't
% treat tbCheckInternet() as an assertion.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addParameter('checkInternetCommand', tbGetPref('checkInternetCommand', 'ping -c 1 -t 2 www.google.com'), @ischar);
parser.addParameter('asAssertion', false, @islogical);
parser.parse(varargin{:});
checkInternetCommand = parser.Results.checkInternetCommand;
asAssertion = parser.Results.asAssertion;

% are we online?
[status, result] = system(checkInternetCommand);
strtrim(result);
isOnline = status == 0;

% if not, do we throw an error?
assert(~asAssertion || isOnline, 'tbCheckInternet:internetUnreachable', result);
