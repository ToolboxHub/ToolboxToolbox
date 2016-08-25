function userFolder = tbUserFolder()
% Get the first folder on the userpath().
%
% userFolder = tbUserFolder() returns the first folder fond on the user's
% userpath().  This is the same as userpath(), up to the first pathsep().
%
% 2016 benjamin.heasly@gmail.com

pathString = userpath();

if isempty(pathString)
    userFolder = '';
    return;
end

firstSeparator = find(pathString == pathsep());
if isempty(firstSeparator)
    userFolder = '';
    return;
end

userFolder = pathString(1:firstSeparator-1);
