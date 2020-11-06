function tbGui
%TBGUI Gui for tbUse()
%
%  Graphical interface for tbUse(). It allows you to
%
%  - Filter available toolboxes: Regular expressions are supported
%  - Select and deploy multiple toolboxes at once
%  - Set the following parameters for tbUse()
%     'cdToFolder' whether to change the directory after deployment
%                  - 'as-specified': As specified in the json file
%                  - true: Same as 'as-specified'. If cdToFolder is absent
%                          in json file, change to root folder of toolbox
%                  - false: Don't change the folder, even if specified in json file
%     'reset' --   how to tbResetMatlabPath() before deployment
%                  values: 'full', 'no-matlab', 'no-self', 'bare', 'as-is'
%     'update' --  whether to update all other toolboxes ('asspecified'/'never')
%                  'asspecified' (default) follows what is specified in the
%                  update field of the toolbox record. 'never' overrides
%                  that field and does not update any of the toolboxes.
%     'useOnce' -- whether to skip the deployment if the toolbox was
%                  already deployed during the current Matlab session. This
%                  only has an effect if 'reset' == 'as-is'
%
%     The defaults for these parameters can be set in the Matlab prefs
%
%
% 2020 Markus Leuthold githubkusi@titlis.org

model = tbgui.Model;
view = tbgui.View;
tbgui.Controller(model, view);