function [status, result, fullCommand] = tbSystem(command, varargin)
% Run a comand with system() and a clean environment.
%
% [status, result] = tbSystem(command) locates the given command on
% the system PATH, then invokes the command.  Clears the shell environment
% beforehand, so unusual environment variables set by Matlab can be
% ignored.
%
% tbSystem( ... 'echo', echo) specifies whether to echo system command
% output to the Matlab Command Window (true) or hide it (false).  The
% default is true, echo command output to the Command Window.  This is good
% for interactive commands.
%
% tbSystem( ... 'keep', keep) specifies a list of existing environment
% variables to preserve in the clean shell environment.  The default is {},
% don't preserve any existing variables.
%
% tbSystem( ... 'dir', dir) specifies a directory dir to cd to, before
% executing the given command.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addRequired('command', @ischar);
parser.addParameter('keep', {}, @iscellstr);
parser.addParameter('echo', true, @islogical);
parser.addParameter('dir', '', @ischar);
parser.parse(command, varargin{:});
command = parser.Results.command;
keep = parser.Results.keep;
echo = parser.Results.echo;
dir = parser.Results.dir;

fullCommand = command;

if ispc()
    if echo
        [status, result] = system(command, '-echo');
    else
        [status, result] = system(command);
    end
    return;
end

% split the command into an executable and its args
firstSpace = find(command == ' ', 1, 'first');
if isempty(firstSpace)
    executable = command;
    args = '';
else
    executable = command(1:firstSpace-1);
    args = command(firstSpace:end);
end

% locate the executable so we can call it with its full path
[status, result] = system(['which ' executable]);
if 0 ~= status
    return;
end
whichExecutable = strtrim(result);

% keep some of the environment
nKeep = numel(keep);
keepVals = cell(1, 2*nKeep);
for kk = 1:nKeep
    keepVals(2*kk-1) = keep(kk);
    keepVals{2*kk} = getenv(keep{kk});
end
keepString = sprintf('%s=%s ', keepVals{:});

% run the command with a clean environment
fullCommand = ['env -i ' keepString whichExecutable args];

% run the command in the given dir, if any
if ~isempty(dir)
    fullCommand = ['cd "' dir '" && ' fullCommand];
end

if echo
    [status, result] = system(fullCommand, '-echo');
else
    [status, result] = system(fullCommand);
end
