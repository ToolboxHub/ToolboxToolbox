function strategy = tbChooseStrategy(record)
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
% implemenation class, in which case the named implementaiton will be
% chosen.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addRequired('record', @isstruct);
parser.parse(record);
record = parser.Results.record;

strategy = [];

if ~isfield(record, 'type')
    return;
end

%% Check the short list of recognized types.
switch record.type
    case 'git'
        strategy = TbGitStrategy();
        return;
end

%% Use type as class name.
if 2 == exist(record.type, 'class')
    constructor = str2func(record.type);
    strategy = feval(constructor);
    return;
end
