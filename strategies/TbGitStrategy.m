classdef TbGitStrategy < TbToolboxStrategy
    % Use Git to obtain and update toolboxes.
    %   https://git-scm.com/
    %
    % 2016 benjamin.heasly@gmail.com
    
    methods (Static)
        function [status, result, fullCommand] = systemInFolder(command, folder)
            originalFolder = pwd();
            try
                tbCheckInternet('asAssertion', true);
                cd(folder);
                [status, result, fullCommand] = tbSystem(command);
            catch err
                status = -1;
                result = err.message;
                fullCommand = command;
            end
            cd(originalFolder);
        end
    end
    
    methods
        function isPresent = checkIfPresent(obj, record, toolboxRoot, toolboxPath)
            % is there a ".git" special folder?
            gitPath = fullfile(toolboxPath, '.git');
            isPresent = 7 == exist(gitPath, 'dir');
        end
        
        function [fullCommand, status, message] = obtain(obj, record, toolboxRoot, toolboxPath)
            
            % clone
            command = sprintf('git clone "%s" "%s"', ...
                record.url, ...
                toolboxPath);
            [status, message, fullCommand] = TbGitStrategy.systemInFolder(command, toolboxRoot);
            if 0 ~= status
                return;
            end
            
            if ~isempty(record.flavor)
                % git checkout sampleBranch
                command = sprintf('git checkout %s', record.flavor);
                [status, message, fullCommand] = TbGitStrategy.systemInFolder(command, toolboxPath);
                if 0 ~= status
                    return;
                end                
            end
        end
        
        function [fullCommand, status, message] = update(obj, record, toolboxRoot, toolboxPath)
            % pull
            if isempty(record.flavor)
                command = sprintf('git pull');
            else
                command = sprintf('git pull origin %s', record.flavor);
            end
            [status, message, fullCommand] = TbGitStrategy.systemInFolder(command, toolboxPath);
        end
    end
end
