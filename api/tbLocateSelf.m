function selfPath = tbLocateSelf()
% Locate the folder where ToolboxToolbox is installed.
%
% selfPath = tbLocateSelf() retrns the path to where the ToolboxToolbox is
% located, based on the location of this function.
%
% 2016 benjamin.heasly@gmail.com

pathHere = fileparts(mfilename('fullpath'));
selfPath = fileparts(pathHere);
