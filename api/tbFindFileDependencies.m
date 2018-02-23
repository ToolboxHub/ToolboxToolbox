function [toolboxes, subdirs, functionNames, unresolved, pList] = tbFindFileDependencies(filename)
% Finds the dependencies of a given m-file (script, function, class)
%
% Syntax:
%   toolboxes = findDependencies(filename)
%   [toolboxes, subdirs] = findDependencies(filename)
%
% Description:
%    Identifies TbTb-managed toolboxes that a given file depends on.
%
% Inputs:
%    filename      - name of m-file to find dependencies for
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
%    02/16/18  jv  wrote it.
%    02/23/18  jv  multiple input files

%% Input validation
parser = inputParser();
parser.addRequired('filename',@(x) ischar(x) || isstring(x) || iscellstr(x))
parser.parse(filename)
filename = cellstr(filename);

%% Add to path
folders = cellfun(@fileparts,filename,'UniformOutput',false);
folders = unique(folders); % no duplicates
folders = folders(~contains(folders,[filesep() '@']) & ~contains(folders,[filesep() '+'])); % no method folders or packages
oldpath = addpath(folders{:});
cleanupObj = onCleanup(@() path(oldpath));

%% Check for code errors
[errors, filepaths] = checkcode(filename,'-id',sprintf('-config=%s',fullfile(tbLocateSelf,'api','checkcodeSettings.txt')));
unchecked = filepaths(~cellfun(@isempty,errors)); % only keep filepaths of files with errors
filename = setdiff(filename,unchecked); % keep filenames without errors

%% Run dependency report
% This matlab builtin finds all functions/scripts run by the input file(s).
% It also lists all "products"/toolboxes (in pList), but that is likely
% incorrect (because of naming conflicts).
try
    [fList,pList] = matlab.codetools.requiredFilesAndProducts(filename(:));
catch e
    switch e.identifier
        case 'MATLAB:depfun:req:InternalNoClassForMethod' 
            % Some class not on path; add and retry
            file = regexp(e.message,'\".*\.m','match');
            file = file{1}(2:end);
            filepath = fileparts(file);
            addpath(filepath);
            [fList,pList] = matlab.codetools.requiredFilesAndProducts(filename(:));
        case 'MATLAB:depfun:req:BadSyntax' 
            % Some code error in a file
            file = regexp(e.message,"\'.*\.m",'match');
            file = file{1}(2:end);
            err = regexp(e.message,":.*",'match');
            err = err{1}(3:end);
            exception = MException('ToolboxToolbox:FindFileDependencies:CodeError',...
            'Dependencies for %s cannot be found, because it contains code errors:\n%s', file, err);
            exception.addCause(e);
            throw(exception);
        otherwise
            % Don't know, rethrow
            rethrow(e);
    end
end
fList = setdiff(fList, filename); % don't return files that were input

%% Parse fList
% We want to parse this list to find toolboxes installed using TbTb.

% First, we need to find where those might be. This is either stored in
% matlab preferences, or it defaults to UserFolder/toolboxes.
toolboxRoot = tbGetPref('toolboxRoot',fullfile(tbUserFolder(), 'toolboxes'));

% We find the fList-entries that have this in them, and mark all the others
% as unresolved:
unresolved = fList(~startsWith(fList,toolboxRoot));
tbtbFiles = fList(startsWith(fList,toolboxRoot));

%% Identify toolboxes, subdirs, functionNames.
% Trim the toolbox root of the paths
tbtbFiles = strrep(tbtbFiles,toolboxRoot,'');

toolboxes = {};
subdirs = containers.Map();
functionNames = containers.Map();

% Split filenames
for i = 1:numel(tbtbFiles)
    [filepath, functionName] = fileparts(tbtbFiles{i});
    filepathparts = split(filepath,filesep);
    
    % First part is empty, second is toolbox name
    toolbox = filepathparts{2};
    
    % Check if this toolbox is installed:
    tbConfig = tbSearchRegistry(toolbox);
    if isempty(tbConfig) % not in registry, see if local
        tbPath = tbLocateToolbox(toolbox);
        if isempty(tbPath) % also not installed locally
            unresolved = [unresolved, tbtbFiles{i}]; % list as unresolved
            continue; % skip
        end
    end
    
    toolboxes = union(toolboxes, toolbox);
    
    % Other parts are subfolders
    subdir = fullfile(filepathparts{3:end});
    if ~isKey(subdirs,toolbox)
        subdirs(toolbox) = {};
    end
    subdirs(toolbox) = union(subdirs(toolbox), subdir);
    
    % Add function to container
    if ~isKey(functionNames,toolbox)
        functionNames(toolbox) = {};
    end
    functionNames(toolbox) = union(functionNames(toolbox), functionName);
end

%% Checks
if ~isempty(toolboxes)
    assert(all(strcmp(keys(subdirs),toolboxes)),"toolboxes and subfolders don't match");
    assert(all(strcmp(keys(functionNames),toolboxes)),"toolboxes and function names don't match");
end

end