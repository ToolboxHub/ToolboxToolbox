function tbNewToolbox
%TBNEWTOOLBOX New TbTb registry file and corresponding git repositories
%  The GUI supports the following workflow
%   - Create new TbTb registry json file
%   - Create local git repository (if needed)
%   - Create remote git repository on a Github instance (if needed)
%
%  USAGE
%    Call "tbNewToolbox" in the root folder of your project
%
%  INSTALLATION
%    Install https://github.com/cli/cli (e.g "winget install --id GitHub.cli")
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
%    NewToolbox.GithubUrls = ["https://git.yourcompany.com/YourOrg" "https://github.com/yourname"]
%    NewToolbox.DefaultGithubVisibility = "public"
%    setpref('ToolboxToolbox', 'NewToolbox', NewToolbox)

model = tbnewtoolbox.Model;
view = tbnewtoolbox.View;
tbnewtoolbox.Controller(model, view);