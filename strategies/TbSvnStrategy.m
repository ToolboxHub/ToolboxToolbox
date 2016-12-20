classdef TbSvnStrategy < TbToolboxStrategy
    % Use Subversion to obtain and update toolboxes.
    %   https://subversion.apache.org/
    %
    %   record.flavor is used as the svn --revision flag
    %   trunk, branch, tag, etc. should be selected using record.subfolder
    %
    % 2017 benjamin.heasly@gmail.com
    
    methods (Static)
        function assertSvnWorks()
            svnCommand = 'svn --version';
            [status, result] = tbSystem(svnCommand, 'echo', false);
            strtrim(result);
            svnWorks = status == 0;
            assert(svnWorks, 'TbSvnStrategy:svnNotWorking', ...
                'Svn seems not to be working.  Got error: <%s>.', result);
        end
    end
    
    methods
        function isPresent = checkIfPresent(obj, record, toolboxRoot, toolboxPath)
            % is there an ".svn" special folder?
            svnPath = fullfile(toolboxPath, '.svn');
            isPresent = 7 == exist(svnPath, 'dir');
        end
        
        function [fullCommand, status, message] = obtain(obj, record, toolboxRoot, toolboxPath)
            
            % fail fast if svn is not working
            TbSvnStrategy.assertSvnWorks();
            
            % checkout
            if isempty(record.flavor)
                command = sprintf('svn checkout "%s" "%s"', ...
                    record.url, ...
                    toolboxPath);
            else
                command = sprintf('svn checkout --revision "%s" "%s" "%s"', ...
                    record.flavor, ...
                    record.url, ...
                    toolboxPath);
            end
            
            [status, message, fullCommand] = obj.systemInFolder(command, toolboxRoot);
        end
        
        function [fullCommand, status, message] = update(obj, record, toolboxRoot, toolboxPath)
            
            % fail fast if svn is not working
            TbSvnStrategy.assertSvnWorks();
            
            % update
            if isempty(record.flavor)
                command = sprintf('svn update "%s"', ...
                    toolboxPath);
            else
                command = sprintf('svn update --revision "%s" "%s"', ...
                    record.flavor, ...
                    toolboxPath);
            end
            
            [status, message, fullCommand] = obj.systemInFolder(command, toolboxPath);
        end
        
        function [status, result, fullCommand] = systemInFolder(obj, command, folder)
            originalFolder = pwd();
            try
                obj.checkInternet('asAssertion', true);
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
end