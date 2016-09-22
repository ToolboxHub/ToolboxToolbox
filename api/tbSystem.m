function [status, result, fullCommand] = tbSystem(command, varargin)
% Run a comand with system() and a clean environment.
%
% [status, result] = tbSystem(command) locates the given command on
% the system PATH, then invokes the command.  Clears the shell environment
% beforehand, so unusual environment variables set by Matlab can be
% ignored.
%
% tbSystem( ... 'keep' keep) specifies a list of existing environment
% variables to preserve in the clean shell environment.  The default is {},
% don't preserve any existing variables.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addRequired('command', @ischar);
parser.addParameter('keep', {}, @iscellstr);
parser.parse(command, varargin{:});
command = parser.Results.command;
keep = parser.Results.keep;

fullCommand = command;

if ispc()
    [status, result] = system(command);
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
[status, result] = system(fullCommand);
