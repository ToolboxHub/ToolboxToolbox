classdef TbGitStrategy < TbToolboxStrategy
    % Use Git to obtain and update toolboxes.
    %   https://git-scm.com/
    %
    % 2016 benjamin.heasly@gmail.com
    
    methods (Static)
        function [status, result] = systemNoLibs(command)
            if isunix()
                commandNoLibs = ['LD_LIBRARY_PATH= ', command];
            elseif ismac()
                commandNoLibs = ['DYLD_LIBRARY_PATH= ', command];
            else
                commandNoLibs = command;
            end
            [status, result] = system(commandNoLibs);
        end
        
        function [status, result] = systemInFolder(command, folder)
            originalFolder = pwd();
            try
                tbCheckInternet('asAssertion', true);
                cd(folder);
                [status, result] = TbGitStrategy.systemNoLibs(command);
            catch err
                status = -1;
                result = err.message;
            end
            cd(originalFolder)
        end
    end
    
    methods
        function isPresent = checkIfPresent(obj, record, toolboxRoot, toolboxPath)
            % is there a ".git" special folder?
            gitPath = fullfile(toolboxPath, '.git');
            isPresent = 7 == exist(gitPath, 'dir');
        end
        
        function [command, status, message] = obtain(obj, record, toolboxRoot, toolboxPath)
            
            % clone
            command = sprintf('git clone "%s" "%s"', ...
                record.url, ...
                toolboxPath);
            [status, message] = TbGitStrategy.systemInFolder(command, toolboxRoot);
            if 0 ~= status
                return;
            end
            
            if ~isempty(record.flavor)
                % make a local branch for a specific branch/tag/commit
                command = sprintf('git fetch origin +%s:%s', ...
                    record.flavor, ...
                    record.flavor);
                [status, message] = TbGitStrategy.systemInFolder(command, toolboxPath);
                if 0 ~= status
                    return;
                end
                
                % check out the new local branch
                command = sprintf('git checkout %s', record.flavor);
                [status, message] = TbGitStrategy.systemInFolder(command, toolboxPath);
                if 0 ~= status
                    return;
                end
            end
        end
        
        function [command, status, message] = update(obj, record, toolboxRoot, toolboxPath)
            % pull
            if isempty(record.flavor)
                command = sprintf('git pull');
            else
                command = sprintf('git pull origin %s', record.flavor);
            end
            [status, message] = TbGitStrategy.systemInFolder(command, toolboxPath);
        end
    end
end
