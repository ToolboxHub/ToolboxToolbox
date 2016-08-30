function [status, result] = tbSystem(command)
% Run a comand with system() and a clean environment.
%
% [status, result] = tbSystem(command) locates the given command on
% the system PATH, then invokes the command.  Clears the shell environment
% beforehand, so unusual environment variables set by Matlab can be
% ignored. 
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addRequired('command', @ischar);
parser.parse(command);
command = parser.Results.command;

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

% run the command with a clean environment
[status, result] = system(['env -i ' whichExecutable args]);
