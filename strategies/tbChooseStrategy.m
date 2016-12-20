function strategy = tbChooseStrategy(record, varargin)
% Choose a TbToolboxStrategy appropriate for the given toolbox record.
%
% strategy = tbChooseStrategy(record) chooses an implementaton of
% TbToolboxStrategy which is appropriate for obtaining and updating the
% toolbox represented by the given record struct.  For example, if the
% given record.type is "git", chooses TbGitStrategy.  Returns an instance
% of the chosen class.
%
% Uses a "short" list of recognized tooblox types, like "git".
% Alternatively, record.type may be the name of a TbToolboxStrategy
% sub-class, in which case the named class will be chosen.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addRequired('record', @isstruct);
parser.addParameter('checkInternetCommand', tbGetPref('checkInternetCommand', ''), @ischar);
parser.parse(record);
record = parser.Results.record;
checkInternetCommand = parser.Results.checkInternetCommand;

strategy = [];

if ~isfield(record, 'type')
    return;
end

%% Default is "include"
if isempty(record.type)
    strategy = TbIncludeStrategy();
    strategy.checkInternetCommand = checkInternetCommand;
    return;
end

%% Check the short list of recognized types.
switch record.type
    case 'git'
        strategy = TbGitStrategy();
    case 'svn'
        strategy = TbSvnStrategy();
    case 'webget'
        strategy = TbWebGetStrategy();
    case 'local'
        strategy = TbLocalStrategy();
    case 'installed'
        strategy = TbInstalledStrategy();
    case 'docker'
        strategy = TbDockerStrategy();
    case 'include'
        strategy = TbIncludeStrategy();
end

%% Use type as class name.
if isempty(strategy) && 2 == exist(record.type, 'class')
    constructor = str2func(record.type);
    strategy = feval(constructor);
end

%% Let the strategy use the current check internet command
if ~isempty(strategy)
    strategy.checkInternetCommand = checkInternetCommand;
end
