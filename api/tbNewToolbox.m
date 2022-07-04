function tbNewToolbox
%TBNEWTOOLBOX new TbTb registry file and corresponding git repositories
%  The GUI supports the following workflow
%   - Create new TbTb registry json file based on an existing folder. 
%
%  INSTALLATION
%    install https://github.com/cli/cli
% 
%  SETUP GH
%    gh auth login -w -h git.yourcompany.com
%
%  SETUP MATLAB 
%    The following variables can be set under the group 'NewToolbox' in the
%    preferences:
%
%    - 'GithubUrls': URLs of Github repositories which are being shown in
%                    the GUI
%    - 'DefaultGithubVisibility': 'public' or 'private'
%
%  EXAMPLE PREFERENCES
%    NewToolbox.GithubUrls = ["https://git.yourcompany.com/YourProject" "https://git.yourcompany.com/11yourname"]
%    NewToolbox.DefaultGithubVisibility = "public"
%    setpref('ToolboxToolbox', 'NewToolbox', NewToolbox)

model = tbnewtoolbox.Model;
view = tbnewtoolbox.View;
tbnewtoolbox.Controller(model, view);