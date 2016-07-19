classdef TbLocalStrategy < TbToolboxStrategy
    % Manage the path for toolboxes that already exist locally.
    %
    % 2016 benjamin.heasly@gmail.com
    
    methods
        function [command, status, message] = obtain(obj, record, toolboxRoot, toolboxPath)
            command = 'checkIfPresent';
            isPresent = checkIfPresent(obj, record, toolboxRoot, toolboxPath);
            if isPresent
                status = 0;
                message = 'local toolbox OK';
            else
                status = -1;
                message = 'local toolbox not found';
            end
        end
        
        function [command, status, message] = update(obj, record, toolboxRoot, toolboxPath)
            [command, status, message] = obj.obtain(record, toolboxRoot, toolboxPath);
        end
        
        function [toolboxPath, displayName] = toolboxPath(obj, toolboxRoot, record, varargin)
            % take local path from url, not toolboxRoot
            
            if 1 == strfind(record.url, 'file://')
                % local absolute path from "file" url scheme
                toolboxPath = record.url(8:end);
            else
                % already a local path
                toolboxPath = record.url;
            end
            
            displayName = record.name;
        end
    end
end
