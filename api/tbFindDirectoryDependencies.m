function [toolboxes, subdirs, functionNames, unresolved, pList] = tbFindDirectoryDependencies(directory)
% Finds dependencies of files in given directory and subdirectories
%
% Syntax:
%   toolboxes = findDependencies(filename)
%   [toolboxes, subdirs] = findDependencies(filename)
%
% Description:
%    Identifies TbTb-managed toolboxes that a given directory depends on.
%
% Inputs:
%    directory     - string(array) or cell-array of strings containing
%                    paths to directory(/ies) to find dependencies for.
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
%    02/23/18  jv  wrote it.

%% Input validation
parser = inputParser();
parser.addRequired('directory',@(x) ischar(x) || isstring(x) || iscellstr(x));
parser.parse(directory)
directory = cellstr(directory);

%% Get all filenames
contents = struct([]);
for i = 1:numel(directory)
    contents = [contents; dir(fullfile(directory{i},'**/*.m'))]; % all .m files in all subdirs
end
filenames = fullfile({contents.folder}',{contents.name}');

%% Run tbFindFileDependencies on all files file
% tbFindFileDependencies can handle multiple filenames, and does so
% efficiently by calling matlab.codetools.requiredFilesAndProducts on the
% whole list at once.
[toolboxes, subdirs, functionNames, unresolved, pList] = tbFindFileDependencies(filenames);
end