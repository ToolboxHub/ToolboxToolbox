classdef TbInstalledStrategy < TbToolboxStrategy
    % Manage the path for Matlab installed toolboxes.
    %
    % Installed Matlab toolboxes require extra care to add them to the
    % Matlab path the way Matlab wants them.  So we add them to the path
    % with custom code here, instead of adding them the usual way in
    % tbDeployToolboxes().
    %
    % 2016 benjamin.heasly@gmail.com
    
    methods
        function [command, status, message] = obtain(obj, record, toolboxRoot, toolboxPath)
            try
                command = 'toolboxdir()';
                installedPath = toolboxdir(record.name);
                
                % choose folders that come from Matlab's own default path
                % and that match the name of this toolbox
                command = 'TbInstalledStrategy.defaultPathMatches()';
                toolboxPathEntries = TbInstalledStrategy.defaultPathMatches(installedPath);
                
                command = 'addpath()';
                addpath(toolboxPathEntries);
                
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
    end
    
    methods (Static)
        % filter default Matlab path for entries with the given prefix
        function pathMatches = defaultPathMatches(pathPrefix)
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
    end
end
