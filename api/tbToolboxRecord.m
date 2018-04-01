function record = tbToolboxRecord(varargin)
% Make a well-formed struct to represent a toolbox.
%
% The idea is to represent a toolbox that we want, using a consistent
% struct format.  Making the struct format consistent is useful because we
% can check for required fields.  We can also put lots of records together
% into a struct array, which is easier to work with than a cell array.
%
% record = tbToolboxRecord() creates a placeholder record with the correct
% fields.
%
% record = tbToolboxRecord( ... name, value) fills in the record with
% fields based on the given names-value pairs.  Unrecognized names
% will be ignored.  The recognized names are:
%   - 'name' unique name to identify the toolbox and the folder that
%   contains it.
%   - 'url' the url where the toolbox can be obtained, like a web url or
%   local file url.  This can be a multi-OS URL.  See
%   tbProcessMultiOSUrl for the format of those.
%   - 'type' the type of repository that contains the toolbox, or class
%   name of a custom TbToolboxStrategy subclass.
%   - 'flavor' optional flavor of toolbox, for example a Git
%   branch/tag/commit to checkout after cloning
%   - 'subfolder' optional toolbox subfolder or cell array of subfolders to
%   add to path, instead of the whole toolbox
%   - 'update' optional update control, if "never", won't attempt to update the toolbox
%   - 'importance' optional error control, if "optional", errors with this
%   toolbox won't cause the whole deployment to fail.
%   - 'hook' Matlab command to eval() after the toolbox is added to the path
%   - 'requirementHook' name of a function to feval() that checks for
%   system requirements that ToolboxToolbox can't install.  Must have the
%   function signature: [status, result, advice] = foo()
%   - 'localHookTemplate' relative path to config script template to be
%   copied to the localHookFolder and run() at the end of deployment
%   - 'toolboxRoot' where to deploy the toolbox, overrides toolboxRoot
%   Matlab preference and toolboxRoot passed to tbDeployToolboxes().
%   - 'pathPlacement' whether to 'append' or 'prepend' to the Matlab path,
%   or skip adding to the path altogether with 'none'.  The default is to
%   'append'.
%   - 'extra' a free-form field for notes, comments, etc., ignored during
%   deployment
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.KeepUnmatched = true;
parser.addParameter('name', '', @ischar);
if (exist('isstring','builtin'))
    parser.addParameter('url', '', @(x) ischar(x) | isstring(x));
else
    parser.addParameter('url', '', @(x) ischar(x));
end
parser.addParameter('type', '', @ischar);
parser.addParameter('flavor', '', @ischar);
parser.addParameter('subfolder', '', @(val) ischar(val) || iscellstr(val) || isstring(val));
parser.addParameter('update', '', @ischar);
parser.addParameter('hook', '', @ischar);
parser.addParameter('requirementHook', '', @ischar);
parser.addParameter('localHookTemplate', '', @ischar);
parser.addParameter('toolboxRoot', '', @ischar);
parser.addParameter('pathPlacement', 'append', @ischar);
parser.addParameter('importance', '', @ischar);
parser.addParameter('extra', '');
parser.parse(varargin{:});

% Let the parser do all the work
record = parser.Results;

% Handle multi-computer URLs
record.url = tbProcessMultiOSUrl(record.url);