classdef TbWebGetStrategy < TbToolboxStrategy
    % Use HTTP GET to obtain a file.  May be a zip file to explode.
    %   see websave, unzip
    %
    % 2016 benjamin.heasly@gmail.com
    
    methods
        
        function [command, status, message] = obtain(obj, record, toolboxRoot, toolboxPath)
            
            try                
                command = 'mkdir';
                if 7 ~= exist(toolboxPath, 'dir')
                    mkdir(toolboxPath);
                end
                
                command = 'websave';
                [~, resourceBase, resourceExt] = fileparts(record.url);
                fileName = fullfile(toolboxPath, [resourceBase, resourceExt]);
               
                obj.checkInternet('asAssertion', true);
                fileName = websave(fileName, record.url);
                
                if strcmp(resourceExt, '.zip')
                    command = 'unzip';
                    unzip(fileName, toolboxPath);
                end
                
            catch err
                status = -1;
                message = err.message;
                return;
            end
            
            % great!
            status = 0;
            message = 'download OK';
        end
        
        function [command, status, message] = update(obj, record, toolboxRoot, toolboxPath)
            % just keep obtaining.  Use record.neverUpdate to prevent this.
            [command, status, message] = obj.obtain(record, toolboxRoot, toolboxPath);
        end
    end
end
