function [toolboxes, subdirs, functionNames, unresolved, pList] = tbFindToolboxDependencies(toolboxName)
% Finds dependencies of codefiles in a given installed toolbox
%
% Syntax:
%   toolboxes = findDependencies(filename)
%   [toolboxes, subdirs] = findDependencies(filename)
%
% Description:
%    Identifies TbTb-managed toolboxes that a given toolbox depends on.
%
% Inputs:
%    directory     - string(array) or cell-array of strings containing
%                    toolbox name(s) to find dependencies for.
%
% Outputs:
%    toolboxes     - cell-array of toolbox names that can be verified as
%                    registered and/or installed.
%    subdirs       - Map of subdirectories per toolbox in toolboxes
%    functionNames - Map of functions per toolbox in toolboxes
%    unresolved    - cell-array of unresolved dependencies. These are files
%                    that are either not in the TbTb toolboxRoot directory,
%                    or ones that we cannot verify as registered or
%                    installed toolboxes.
%    pList         - product-list as returned by Matlab's
%                    requiredFilesAndProducts. This is likely incorrect,
%                    because of naming conflicts.
%
% Optional key/value pairs:
%    None.
%

% History:
%    02/23/18  jv  wrote it. Wrapper around tbFindDirectoryDependencies.

directory = tbLocateToolbox(toolboxName);
[toolboxes, subdirs, functionNames, unresolved, pList] = tbFindDirectoryDependencies(directory);

end

