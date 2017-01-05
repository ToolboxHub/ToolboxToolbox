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
            command = sprintf('git clone "%s" "%s"', ...
                record.url, ...
                toolboxPath);
            [status, message, fullCommand] = obj.systemInFolder(command, toolboxRoot);
            if 0 ~= status
                return;
            end
            
            if ~isempty(record.flavor)
                % git checkout sampleBranch
                command = sprintf('git checkout %s', record.flavor);
                [status, message, fullCommand] = obj.systemInFolder(command, toolboxPath);
                if 0 ~= status
                    return;
                end
            end
        end
        
        function [fullCommand, status, message] = update(obj, record, toolboxRoot, toolboxPath)
            
            if ~obj.checkInternet('echo', false)
                % toolbox already exists, but offline prevents update
                [fullCommand, status, message] = obj.skipUpdate();
                return;
            end
            
            % fail fast if git is not working
            TbGitStrategy.assertGitWorks();
            
            % pull
            if isempty(record.flavor)
                command = sprintf('git pull');
            else
                command = sprintf('git pull origin %s', record.flavor);
            end
            [status, message, fullCommand] = obj.systemInFolder(command, toolboxPath);
        end
        
        function [status, result, fullCommand] = systemInFolder(obj, command, folder, varargin)
            originalFolder = pwd();
            try
                obj.checkInternet('asAssertion', true);
                cd(folder);
                [status, result, fullCommand] = tbSystem(command, varargin{:});
            catch err
                status = -1;
                result = err.message;
                fullCommand = command;
            end
            cd(originalFolder);
        end
        
        function flavor = detectFlavor(obj, record)
            % preserve declared flavor, if any
            if ~isempty(record.flavor)
                flavor = record.flavor;
                return;
            end
            
            % detect flavor with git command.
            toolboxPath = tbLocateToolbox(record, obj.prefs);
            command = 'git rev-parse HEAD';
            [status, result] = obj.systemInFolder(command, toolboxPath, ...
                'echo', false);
            if 0 == status
                flavor = strtrim(result);
            else
                flavor = '';
            end
        end
        
        function url = detectOriginUrl(obj, record)
            % try to detect the url from where this was cloned
            toolboxPath = tbLocateToolbox(record, obj.prefs);
            command = 'git config --get remote.origin.url';
            [status, result] = obj.systemInFolder(command, toolboxPath, ...
                'echo', false);
            if 0 == status
                url = strtrim(result);
            else
                url = '';
            end
        end
    end
end
