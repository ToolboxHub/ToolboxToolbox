function absolutePath = tbHomePathToAbsolute(homePath)
% Convert a "home path" that begins with "~" to a full absolute path.
%
% This is intended as a one-liner utility for converting user home paths to
% full, absolute paths.  We often want to use home paths, but some tools
% require the absollute version.  So blah.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addRequired('homePath', @ischar);
parser.parse(homePath);
homePath = parser.Results.homePath;

absolutePath = homePath;
if isempty(homePath);
    return;
end

if '~' == homePath(1)
    % ask system for the value of ~
    home = getenv('HOME');
    absolutePath = [home homePath(2:end)];
end
