classdef TbInstalledStrategy < TbToolboxStrategy
    % Manage the path for Matlab installed toolboxes.
    %
    % Installed Matlab toolboxes require extra care to add them to the
    % Matlab path the way Matlab wants them.
    %
    % 2016 benjamin.heasly@gmail.com
    
    methods
        function [command, status, message] = obtain(obj, record, toolboxRoot, toolboxPath)
            try
                command = 'toolboxdir()';
                toolboxdir(record.name);
                message = 'installed toolbox found OK';
                status = 0;
            catch err
                message = err.message;
                status = -1;
            end
        end
        
        function [command, status, message] = update(obj, record, toolboxRoot, toolboxPath)
            [command, status, message] = obj.obtain(record, toolboxRoot, toolboxPath);
        end
        
        function [toolboxPath, displayName] = toolboxPath(obj, toolboxRoot, record, varargin)
            % take local path from Matlab folder, not toolboxRoot
            try
                toolboxPath = toolboxdir(record.name);
            catch
                toolboxPath = '';
            end
            displayName = record.name;
        end
        
        function toolboxPath = addToPath(obj, record, toolboxPath)
            if strcmp('none', record.pathPlacement)
                % skip path construction and adding
                return;
            end
            
            % start with folders that come from Matlab's own default path
            % filter to get the ones that match the name of this toolbox
            toolboxPath = toolboxdir(record.name);
            toolboxPathEntries = TbInstalledStrategy.factoryPathMatches(toolboxPath);
            switch record.pathPlacement
                case 'prepend'
                    addpath(toolboxPathEntries, '-begin');
                case 'append'
                    addpath(toolboxPathEntries, '-end');
                otherwise
                    % default is append
                    addpath(toolboxPathEntries, '-end');
            end
        end
    end
    
    methods (Static)
        % filter default Matlab path for entries with the given prefix
        function pathMatches = factoryPathMatches(pathPrefix)
            defaultPath = tbCaptureDefaultPath();
            scanResults = textscan(defaultPath, '%s', 'delimiter', pathsep());
            pathElements = scanResults{1};
            
            % locate prefix matches
            isMatchFun = @(s) TbInstalledStrategy.isPrefix(s, pathPrefix);
            isMatch = cellfun(isMatchFun, pathElements);
            
            % print a new, clean path
            matchElements = pathElements(isMatch);
            pathMatches = sprintf(['%s' pathsep()], matchElements{:});
        end
        
        % is b a prefix of a?
        function prefix = isPrefix(a, b)
            found = strfind(a, b);
            prefix = 1 == numel(found) && 1 == found;
        end
        
        % discover names of extra installed toolboxes
        function toolboxNames = installedToolboxNames()
            % need to restore path, otherwise we can't detect toolboxes!
            oldPath = path();
            restoredefaultpath();
            try
                
                
                wid = 'MATLAB:ver:ProductNameDeprecated';
                oldWarningState = warning('query', wid);
                warning('off', wid);
                
                % look in matlabroot()/toolboxes for built-in and installed toolboxes
                toolboxFolders = dir(toolboxdir(''));
                nToolboxes = numel(toolboxFolders);
                isInstalled = false(1, nToolboxes);
                for tt = 1:nToolboxes
                    toolboxName = toolboxFolders(tt).name;
                    
                    % skip folders that can't be considered "installed" toolboxes
                    if any(strcmp(toolboxName, {'.', '..', 'matlab'}))
                        continue;
                    end
                    
                    % detect installed toolboxes as those that have version info
                    versionInfo = ver(toolboxName);
                    isInstalled(tt) = ~isempty(versionInfo);
                end
                
                warning(oldWarningState.state, wid);
                
                toolboxNames = {toolboxFolders(isInstalled).name};
            catch err
                path(oldPath);
                rethrow(err);
            end
            path(oldPath);
        end
    end
end
