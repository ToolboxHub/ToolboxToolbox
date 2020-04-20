classdef Model < handle
    %MODEL MVC Model class for tbNewToolbox()
    %
    %  SEE ALSO tbnewtoolbox.View, tbnewtoolbox.Controller
    %
    %  2021 Markus Leuthold markus.leuthold@sonova.com
    
    properties
        toolboxNames
        prefs
        subfolder
    end
    
    methods(Access = private)
        function s = getToolboxesString(~, toolboxNames)
            assert(iscell(toolboxNames))
            if length(toolboxNames) == 1
                s = ['''' toolboxNames{1} ''''];
            else
                x = join(toolboxNames, ''', ''');
                s = ['{''' x{1} '''}'];
            end
        end
        
        function cp = canonicalPath(~, p)
            % make path strings unambigous, comparable and printable
            cp = strrep(p, '\', '/');
        end
    end
    
    methods
        function self = Model
            [~, self.toolboxNames] = tbGetToolboxNames;
            self.prefs = tbParsePrefs(tbGetPersistentPrefs);
            toolboxRoot = self.getToolboxRoot;
            isUnderToolboxRoot = startsWith(self.canonicalPath(pwd), toolboxRoot, 'IgnoreCase', true);
            assert(isUnderToolboxRoot, 'tbNewToolbox:NotUnderToolboxRoot', ...
                "Your new toolbox needs to be located under the current toolbox root " + toolboxRoot)
        end
        
        function s = getGithubUrls(~)
            s = getpref('ToolboxToolbox', 'NewToolbox').GithubUrls;
        end
        
        function s = getDefaultGithubVisibility(~)
            pref = getpref('ToolboxToolbox', 'NewToolbox');
            if isfield(pref, 'DefaultGithubVisibility')
                s = pref.DefaultGithubVisibility;
                assert(ismember(s, {'private' 'public' 'internal'}), ...
                    'NewToolbox:BadDefaultVisibility', 'default visibiliy needs to be one of private, public, internal')
            else
                s = 'public';
            end
        end
        
        function tn = getNewToolboxName(self)
            gitRoot = self.getGitRoot;
            if isempty(gitRoot)
                % no git exist yet, assume this is the root dir for a
                % future git repo
                gitRoot = pwd;
            end
            
            tn = self.getCurrentToolboxName(gitRoot);
        end
        
        function repoName = getDefaultRepoName(self)
            [~, repoName] = fileparts(self.getNewToolboxName);
        end
        
        function checkGhInstallation(~)
            cmd = 'gh --version';
            [~, out] = system(cmd);
            assert(contains(out, 'gh version'), 'tbtb:GhNotFound', ...
                'Cannot find gh. Please install from <a href="https://github.com/cli/cli#installation">Github</a>.')
        end
        
        function createLocalGitRepo(~)
            cmd = 'git init';
            [fail, out] = system(cmd);
            assert(~fail, 'CreateLocalGitRepo:BadGitInit', out)
        end
        
        function fullUrl = fullGithubUrl(~, url, repoName)
            fullUrl = [url '/' repoName];
        end
        
        function createRemoteGitRepo(self, shortDescription, visibility, url)
            self.checkGhInstallation
            ghUrl = erase(url, 'https://');
            cmd = ['gh repo create ' ghUrl ' -y -d "' shortDescription '" --' visibility];
            [tf, out] = system(cmd);
            assert(tf == 0, """" + cmd + """ failed" + newline + out)
        end
        
        function r = getToolboxRoot(self)
            r = self.canonicalPath(tbGetPersistentPrefs().toolboxRoot);
        end
        
        function toolboxName = getCurrentToolboxName(self, currentRoot)
            toolboxName = erase(strrep(currentRoot, '\', '/'), self.getToolboxRoot);
            
            % delete leading slash
            toolboxName = regexprep(toolboxName, '^/', '');
        end
        
        function gitRoot = getGitRoot(~)
            [retVal, out] = system('git rev-parse --show-toplevel');
            if retVal == 0
                gitRoot = strip(out);
            else
                gitRoot = [];
            end
        end
        
        function wellFormedRecord = getMainRecord(~, toolboxName, url, subfolder, pathPlacement)
            record.name = toolboxName;
            record.subfolder = subfolder;
            record.type = 'git';
            record.url = url;
            record.pathPlacement = pathPlacement;
            %             record.cdToFolder = self.cdToFolderEditField.Value;
            wellFormedRecord = tbToolboxRecord(record);
        end
        
        function wellFormedRecords = getDependencyRecords(~, dependencies)
            wellFormedRecords = [];
            for k = 1:length(dependencies)
                record.name = strrep(dependencies{k}, '\', '/');
                record.type = 'include';
                wellFormedRecords = [wellFormedRecords tbToolboxRecord(record, 'pathPlacement', '')]; %#ok<AGROW>
            end
        end
        
        function records = getRecords(self, toolboxName, url, subfolder, dependencies, pathPlacement)
            mainRecord = self.getMainRecord(toolboxName, url, subfolder, pathPlacement);
            dependencyRecords = self.getDependencyRecords(dependencies);
            records = [mainRecord, dependencyRecords];
        end
        
        function filePath = getConfigFilePath(~, toolboxName)
            prefs = tbParsePrefs(tbGetPersistentPrefs);
            registryRoot = tbLocateToolbox(prefs.registry);
            configRoot = fullfile(registryRoot, prefs.registry.subfolder);
            [~, configDirs] = fileparts(toolboxName);
            folder = fullfile(configRoot, configDirs);
            if ~isfolder(folder)
                mkdir(folder)
            end
            filePath = fullfile(configRoot, [toolboxName '.json']);
        end
        
        function writeRecords(~, records, filePath)
            % create subfolders if needed
            subfolder = fileparts(filePath);
            if ~isfolder(subfolder)
                disp(subfolder + " doesn't exist, create folder");
                mkdir(subfolder);
            end
            disp("write config file to " + filePath)
            savejson('', records, 'filename', filePath, 'SkipEmpty', true)
        end
        
        function createToolbox(self, shortDescription, subfolder, dependencies, pathPlacement, visibility, baseUrl, repoName)
            gitRoot = self.getGitRoot;
            if isempty(gitRoot)
                disp("No git repo exists in current folder, create a new one")
                self.createLocalGitRepo
                gitRoot = pwd;
            end
            
            url = self.fullGithubUrl(baseUrl, repoName);
            self.createRemoteGitRepo(shortDescription, visibility, url);
            toolboxName = self.getCurrentToolboxName(gitRoot);
            records = self.getRecords(toolboxName, url, subfolder, dependencies, pathPlacement);
            filePath = self.getConfigFilePath(toolboxName);
            self.writeRecords(records, filePath)
        end
        
        function filteredToolboxNames = filterToolboxes(self, filterStr)
            if isempty(filterStr)
                % If filter string is empty, e.g after clearing the filter
                % edit box, the user most likely wants to see everything
                filterStr = '.*';
            end
            idx = ~cellfun(@isempty, regexpi(self.toolboxNames, filterStr));
            filteredToolboxNames = self.toolboxNames(idx);
        end
        
        function s = getPlannedActions(self)
            % local git repo
            s = "Current working folder: " + pwd;
            gitRoot = self.getGitRoot;
            if isempty(gitRoot)
                gitRoot = pwd;
                s = [s "No git repo exists in current folder, create new git local repo in " + pwd];
            else
                s = [s "git repo present in current working folder"];
            end
            
            % remote git repo
            toolboxName = self.getCurrentToolboxName(gitRoot);
            s = [s "Create repo " + toolboxName + " on Github"];
            
            % config file
            s = [s "Create config file in " + self.getConfigFilePath(toolboxName)];
        end
    end
end

