classdef TbProjectTest  < matlab.unittest.TestCase
    % Test the ToolboxToolbox for a local project.
    %
    % The ToolboxToolbox should be able to deploy an existing project in
    % the projectRoot, with dependencies in the toolboxRoot.
    %
    % 2016 benjamin.heasly@gmail.com
    
    properties
        toolboxRoot = fullfile(tempdir(), 'toolboxes');
        projectRoot = fullfile(tempdir(), 'projects');
        localProjectFile = 'local-project-file.txt';
        originalMatlabPath;
        originalDirectory;
    end
    
    methods (TestMethodSetup)
        function saveOriginalMatlabState(obj)
            obj.originalMatlabPath = path();
            tbResetMatlabPath('reset', 'full');
            
            obj.originalDirectory = pwd();
        end
        
        function cleanProjectFolder(obj)
            % copy known file to a temp "project", not on the path
            if 7 == exist(obj.projectRoot, 'dir')
                rmdir(obj.projectRoot, 's');
            end
            mkdir(obj.projectRoot);
        end
    end
    
    methods (TestMethodTeardown)
        function restoreOriginalMatlabState(obj)
            path(obj.originalMatlabPath);
            cd(obj.originalDirectory);
        end
    end
    
    methods
        function config = createProject(obj, projectName, configName, subfolder, varargin)
            % a file we should find on path
            pathHere = fileparts(mfilename('fullpath'));
            fixtureFile = fullfile(pathHere, 'fixture', 'project-file.txt');
            projectFolder = fullfile(obj.projectRoot, subfolder);
            targetFile = fullfile(projectFolder, obj.localProjectFile);
            targetFolder = fileparts(targetFile);
            if 7 ~= exist(targetFolder, 'dir')
                mkdir(targetFolder);
            end
            copyfile(fixtureFile, targetFile);
            
            % the project itself, and a regular toolbox dependency
            config = [ ...
                tbToolboxRecord('name', projectName, 'type', 'local', 'url', projectFolder, varargin{:}), ...
                tbToolboxRecord('name', 'sample-repo', 'type', 'include'), ...
                ];
            
            configPath = fullfile(projectFolder, configName);
            configFolder = fileparts(configPath);
            if 7 ~= exist(configFolder, 'dir')
                mkdir(configFolder);
            end
            tbWriteConfig(config, 'configPath', configPath);
        end
    end
    
    methods (Test)
        function subfolderSuccessTest(obj)
            config = obj.createProject('Foo', 'configuration/Foo.json', 'my/path/Foo');
            nRecords = numel(config);
            
            prefs = tbParsePrefs( ...
                'projectRoot', obj.projectRoot, ...
                'toolboxRoot', obj.toolboxRoot);
            results = tbUseProject('Foo', prefs);
            obj.assertNumElements(results, nRecords);
            obj.assertEqual([results.status], zeros(1, nRecords));
            
            % should find a project file on the path
            whichProjectFile = which(obj.localProjectFile);
            expectedProjectFile = fullfile(obj.projectRoot, 'my/path/Foo', obj.localProjectFile);
            obj.assertEqual(whichProjectFile, expectedProjectFile);
            
            % should find a toolbox file on the path
            whichToolboxFile = which('master.txt');
            expectedToolboxFile = fullfile(obj.toolboxRoot, 'sample-repo', 'master.txt');
            obj.assertEqual(whichToolboxFile, expectedToolboxFile);
        end
        
        function normalSuccessTest(obj)
            config = obj.createProject('Foo', 'Foo.json', 'Foo');
            nRecords = numel(config);
            
            prefs = tbParsePrefs( ...
                'projectRoot', obj.projectRoot, ...
                'toolboxRoot', obj.toolboxRoot);
            results = tbUseProject('Foo', prefs);
            obj.assertNumElements(results, nRecords);
            obj.assertEqual([results.status], zeros(1, nRecords));
            
            % should find a project file on the path
            whichProjectFile = which(obj.localProjectFile);
            expectedProjectFile = fullfile(obj.projectRoot, 'Foo', obj.localProjectFile);
            obj.assertEqual(whichProjectFile, expectedProjectFile);
            
            % should find a toolbox file on the path
            whichToolboxFile = which('master.txt');
            expectedToolboxFile = fullfile(obj.toolboxRoot, 'sample-repo', 'master.txt');
            obj.assertEqual(whichToolboxFile, expectedToolboxFile);
        end
        
        function noPathSuccessTest(obj)
            % don't add Foo to the path, but do add its dependencies
            config = obj.createProject('Foo', 'Foo.json', 'Foo', 'pathPlacement', 'none');
            nRecords = numel(config);
            
            prefs = tbParsePrefs( ...
                'projectRoot', obj.projectRoot, ...
                'toolboxRoot', obj.toolboxRoot);
            results = tbUseProject('Foo', ...
                'cdToProject', false, ...
                prefs);
            obj.assertNumElements(results, nRecords);
            obj.assertEqual([results.status], zeros(1, nRecords));
            
            % should *not* find a project file on the path
            whichProjectFile = which(obj.localProjectFile);
            obj.assertEmpty(whichProjectFile);
            
            % should find a toolbox file on the path
            whichToolboxFile = which('master.txt');
            expectedToolboxFile = fullfile(obj.toolboxRoot, 'sample-repo', 'master.txt');
            obj.assertEqual(whichToolboxFile, expectedToolboxFile);
        end
        
        function cdToProjectTest(obj)
            config = obj.createProject('Foo', 'Foo.json', 'Foo');
            nRecords = numel(config);
            
            % start in an arbitrary directory
            cd(tempdir());
            
            prefs = tbParsePrefs( ...
                'projectRoot', obj.projectRoot, ...
                'toolboxRoot', obj.toolboxRoot);
            results = tbUseProject('Foo', ...
                'cdToProject', true, ...
                prefs);
            obj.assertNumElements(results, nRecords);
            obj.assertEqual([results.status], zeros(1, nRecords));
            
            % should have changed to project directory
            projectDir = tbLocateProject(results(1), prefs);
            currentDir = pwd();
            obj.assertEqual(currentDir, projectDir);
        end
        
        function noCdToProjectTest(obj)
            config = obj.createProject('Foo', 'Foo.json', 'Foo');
            nRecords = numel(config);
            
            % start in an arbitrary directory
            cd(tempdir());
            startDir = pwd();
                        
            prefs = tbParsePrefs( ...
                'projectRoot', obj.projectRoot, ...
                'toolboxRoot', obj.toolboxRoot);
            results = tbUseProject('Foo', ...
                'cdToProject', false, ...
                prefs);
            obj.assertNumElements(results, nRecords);
            obj.assertEqual([results.status], zeros(1, nRecords));
            
            % should not have changed to project directory
            currentDir = pwd();
            obj.assertEqual(currentDir, startDir);
        end
        
        function bogusTest(obj)
            obj.createProject('Foo', 'Foo.json', 'Foo');
            
            prefs = tbParsePrefs( ...
                'projectRoot', obj.projectRoot, ...
                'toolboxRoot', obj.toolboxRoot);
            results = tbUseProject('bogus', prefs);
            obj.assertEmpty(results);
        end
        
        function missingJsonTest(obj)
            obj.createProject('Foo', 'Bar.json', 'Foo');
            
            prefs = tbParsePrefs( ...
                'projectRoot', obj.projectRoot, ...
                'toolboxRoot', obj.toolboxRoot);
            results = tbUseProject('Foo', prefs);
            obj.assertEmpty(results);
        end
        
        function missingFolderTest(obj)
            obj.createProject('Foo', 'Foo.json', 'Bar');
            
            prefs = tbParsePrefs( ...
                'projectRoot', obj.projectRoot, ...
                'toolboxRoot', obj.toolboxRoot);
            results = tbUseProject('Foo', prefs);
            obj.assertEmpty(results);
        end
    end
end
