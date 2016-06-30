classdef TbGitStrategy < TbToolboxStrategy
    % Use Git to obtain and update toolboxes.
    %   https://git-scm.com/
    %
    % 2016 benjamin.heasly@gmail.com
    
    methods
        function isPresent = checkIfPresent(obj, record, toolboxRoot, toolboxPath)
            % is there a ".git" special folder?
            gitPath = fullfile(toolboxPath, '.git');
            isPresent = 7 == exist(gitPath, 'dir');
        end
        
        function [command, status, message] = obtain(obj, record, toolboxRoot, toolboxPath)
            
            % clone
            command = sprintf('git -C "%s" clone "%s" "%s"', ...
                toolboxRoot, record.url, record.name);
            [status, message] = system(command);
            if 0 ~= status
                return;
            end
            
            if ~isempty(record.flavor)
                % make a local branch for a specific branch/tag/commit
                command = sprintf('git -C "%s" fetch origin +%s:%s', toolboxPath, record.flavor, record.flavor);
                [status, message] = system(command);
                if 0 ~= status
                    return;
                end
                
                % check out the new local branch
                command = sprintf('git -C "%s" checkout %s', toolboxPath, record.flavor);
                [status, message] = system(command);
                if 0 ~= status
                    return;
                end
            end
        end
        
        function [command, status, message] = update(obj, record, toolboxRoot, toolboxPath)
            % pull
            if isempty(record.flavor)
                command = sprintf('git -C "%s" pull', toolboxPath);
            else
                command = sprintf('git -C "%s" pull origin %s', toolboxPath, record.flavor);
            end
            [status, message] = system(command);
        end
    end
end
