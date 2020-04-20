function tbNewToolbox
% INSTALL
% - install https://github.com/cli/cli
% 
% SETUP GH
%   gh auth login -w -h git.sonova.com
%
% SETUP MATLAB
%   NewToolbox.GithubUrls = ["https://git.sonova.com/EarSpace" "https://git.sonova.com/11mleuthold"]
%   NewToolbox.DefaultGithubVisibility = "public"
%   setpref('ToolboxToolbox', 'NewToolbox', NewToolbox)

model = tbnewtoolbox.Model;
view = tbnewtoolbox.View;
tbnewtoolbox.Controller(model, view);