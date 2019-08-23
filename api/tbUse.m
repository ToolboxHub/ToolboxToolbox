function results = tbUse(registered, varargin)
% Deploy registered toolboxes by name.
%
% The goal here is to make it a one-liner to fetch toolboxes that are
% registerd on ToolboxHub and add them to the Matlab path.  This should
% automate several steps that we usually do by hand, which is good for
% consistency and convenience.
%
% This function uses ToolboxToolbox shared parameters and preferences.  See
% tbParsePrefs().
%
% results = tbUse('foo') fetches one toolbox named 'foo' from ToolboxHub
% and adds it to the Matlab path.
%
% results = tbUse({'foo', 'bar', ...}) fetches toolboxes named
% 'foo', 'bar', etc. from ToolboxHub and adds them to the matlab path.
%
% 2016 benjamin.heasly@gmail.com

prefs = tbParsePrefs(varargin{:});

parser = inputParser();
parser.addRequired('registered', @(r) ischar(r) || iscellstr(r));
parser.parse(registered);
registered = parser.Results.registered;

% convert convenient string form to general list form
if ischar(registered)
    registered = {registered};
end

results = tbDeployToolboxes(prefs, 'registered', registered);

if ~isempty(results) && ~isempty(results(1).cdToFolder)
    fdr = fullfile(tbLocateToolbox(results(1).name), results(1).cdToFolder);
    fprintf('Changing to %s\n', fdr);
    cd(fdr)
end
