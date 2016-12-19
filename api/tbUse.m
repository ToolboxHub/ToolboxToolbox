function results = tbUse(registered, varargin)
% Deploy registered toolboxes by name.
%
% The goal here is to make it a one-liner to fetch toolboxes that are
% registerd on ToolboxHub and add them to the Matlab path.  This should
% automate several steps that we usually do by hand, which is good for
% consistency and convenience.
%
% results = tbUse('foo') fetches one toolbox named 'foo' from ToolboxHub
% and adds it to the Matlab path.
%
% results = tbUse({'foo', 'bar', ...}) fetches toolboxes named
% 'foo', 'bar', etc. from ToolboxHub and adds them to the matlab path.
%
% tbUse(... 'name', value) specify additional name-value pairs to specify
% how toolboxes should be deployed.  See tbDeployToolboxes() which shares
% parameters with this function.
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('registered', @(r) ischar(r) || iscellstr(r));
parser.parse(registered, varargin{:});
registered = parser.Results.registered;

% convert convenient string form to general list form
if ischar(registered)
    registered = {registered};
end

results = tbDeployToolboxes( ...
    varargin{:}, ...
    'registered', registered);
