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
            result = strtrim(result);
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
            
            [status, message, fullCommand] = tbSystem(command, 'echo', obj.prefs.verbose);
        end
        
        function [fullCommand, status, message] = update(obj, record, toolboxRoot, toolboxPath)
            
            if ~obj.prefs.online
                % toolbox already exists, but offline prevents update
                [fullCommand, status, message] = obj.skipUpdate();
                return;
            end
            
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
            
            [status, message, fullCommand] = tbSystem(command, 'echo', obj.prefs.verbose);
        end
        
        function flavor = detectFlavor(obj, record)
            % preserve declared flavor, if any
            if ~isempty(record.flavor)
                flavor = record.flavor;
                return;
            end
            
            % detect flavor with svn command.
            toolboxPath = tbLocateToolbox(record, obj.prefs);
            command = sprintf('svn info "%s"', toolboxPath);
            [status, result] = tbSystem(command, 'echo', false);
            if 0 == status
                % scrape out just the revision number
                tokens = regexp(result, '^Revision: (\d+)$', ...
                    'tokens', ...
                    'lineanchors');
                if ~isempty(tokens)
                    flavor = tokens{1}{1};
                    return;
                end
            end
            flavor = '';
        end
    end
end
