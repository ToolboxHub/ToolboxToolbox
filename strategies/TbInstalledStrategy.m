classdef TbInstalledStrategy < TbToolboxStrategy
    % Manage the path for Matlab installed toolboxes.
    %
    % 2016 benjamin.heasly@gmail.com
    
    methods
        function [command, status, message] = obtain(obj, record, toolboxRoot, toolboxPath)
            command = 'checkIfPresent';
            isPresent = checkIfPresent(obj, record, toolboxRoot, toolboxPath);
            if isPresent
                status = 0;
                message = 'installed toolbox OK';
            else
                status = -1;
                message = 'installed toolbox not found';
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
end
