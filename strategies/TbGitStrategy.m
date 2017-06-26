classdef TbGitStrategy < TbToolboxStrategy
    % Use Git to obtain and update toolboxes.
    %   https://git-scm.com/
    %
    % 2016 benjamin.heasly@gmail.com
    
    methods (Static)
        function assertGitWorks()
            gitCommand = 'git --version';
            [status, result] = tbSystem(gitCommand, 'echo', false);
            result = strtrim(result);
            gitWorks = status == 0;
            assert(gitWorks, 'TbGitStrategy:gitNotWorking', ...
                'Git seems not to be working.  Got error: <%s>.', result);
        end
    end
    
    methods
        function isPresent = checkIfPresent(obj, record, toolboxRoot, toolboxPath)
            % is there a ".git" special folder?
            gitPath = fullfile(toolboxPath, '.git');
            isPresent = 7 == exist(gitPath, 'dir');
        end
        
        function [fullCommand, status, message] = obtain(obj, record, toolboxRoot, toolboxPath)
            
            % fail fast if git is not working
            TbGitStrategy.assertGitWorks();
            
            % clone
            command = sprintf('git clone "%s" "%s"', record.url, toolboxPath);
            [status, message, fullCommand] = tbSystem(command, 'echo', obj.prefs.verbose);
            if 0 ~= status
                return;
            end
            
            if ~isempty(record.flavor)
                % git checkout sampleBranch
                command = sprintf('git checkout %s', record.flavor);
                [status, message, fullCommand] = tbSystem(command, 'echo', obj.prefs.verbose, 'dir', toolboxPath);
                if 0 ~= status
                    return;
                end
            end
        end
        
        function [fullCommand, status, message] = update(obj, record, toolboxRoot, toolboxPath)
            
            if ~obj.prefs.online
                % toolbox already exists, but offline prevents update
                [fullCommand, status, message] = obj.skipUpdate();
                return;
            end
            
            % fail fast if git is not working
            TbGitStrategy.assertGitWorks();
            
            % pull
            if isempty(record.flavor)
                command = 'git pull';
            else
                command = sprintf('git pull origin %s', record.flavor);
            end
            [status, message, fullCommand] = tbSystem(command, 'echo', obj.prefs.verbose, 'dir', toolboxPath);
        end
        
        function [flavor,flavorlong,originflavorlong] = detectFlavor(obj, record)
            % preserve declared flavor, if any
            if ~isempty(record.flavor)
                flavor = record.flavor;
                return;
            end
            
            % detect flavor with git command.
            toolboxPath = tbLocateToolbox(record, obj.prefs);
            command = 'git rev-parse --short HEAD';
            [status, result] = tbSystem(command, 'echo', false, 'dir', toolboxPath);
            if 0 == status
                flavor = strtrim(result);
            else
                flavor = '';
            end
            
            command = 'git rev-parse HEAD';
            [status, result] = tbSystem(command, 'echo', false, 'dir', toolboxPath);
            if 0 == status
                flavorlong = strtrim(result);
            else
                flavorlong = '';
            end
            
            url = obj.detectOriginUrl(record);
            command = ['git ls-remote ' url ' HEAD'];
            [status, result] = tbSystem(command, 'echo', false, 'dir', toolboxPath);
            if 0 == status
                originflavorlong = sscanf(result,'%s',1);
            else
                originflavorlong = '';
            end
        end
        
        function url = detectOriginUrl(obj, record)
            % try to detect the url from where this was cloned
            toolboxPath = tbLocateToolbox(record, obj.prefs);
            command = 'git config --get remote.origin.url';
            [status, result] = tbSystem(command, 'echo', false, 'dir', toolboxPath);
            if 0 == status
                url = strtrim(result);
            else
                url = '';
            end
        end
    end
end
