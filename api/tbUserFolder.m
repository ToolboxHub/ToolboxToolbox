function userFolder = tbUserFolder()
% Get the first folder on the userpath().
%
% userFolder = tbUserFolder() returns the first folder fond on the user's
% userpath().  This is the same as userpath(), up to the first pathsep().
%
% 2016 benjamin.heasly@gmail.com

% try to get Matlab's special "user" path entries
%    or punt with system variables
pathString = userpath();
if isempty(pathString)
    if ispc()
        userFolder = fullfile(getenv('HOMEDRIVE'), getenv('HOMEPATH'));
    else
        userFolder = getenv('HOME');
    end
    return;
end

% take the first path entry, without any delimiter like ":"
firstSeparator = find(pathString == pathsep(), 1, 'first');
if isempty(firstSeparator)
    userFolder = pathString;
else
    userFolder = pathString(1:firstSeparator-1);
end
