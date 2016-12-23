classdef TbGitAndSanityTest < matlab.unittest.TestCase
    % Test the Toolbox Toolbox against a contrived Githib repository.
    %
    % The contrived GitHub repository at
    % https://github.com/ToolboxHub/sample-repo.git has and expected
    % branch, tag, and commit, each with some expected and unexpected
    % files.
    %
    % The Toolbox Toolbox should be able to fetch each flavor of the
    % repository.  This test suite will verify the expected and unexpected
    % files.
    %
    % 2016 benjamin.heasly@gmail.com
    
    properties
        configPath = fullfile(tempdir(), 'toolbox_config.json');
        toolboxRoot = fullfile(tempdir(), 'toolboxes');
        alternateRoot = fullfile(tempdir(), 'toolboxes-alternate');
        originalMatlabPath;
    end
    
    methods (TestMethodSetup)
        function saveOriginalMatlabState(obj)
            obj.originalMatlabPath = path();
            tbResetMatlabPath('full');
        end
        
        function cleanUpTempFiles(obj)
            if 2 == exist(obj.configPath, 'file')
                delete(obj.configPath);
            end
            
            if 7 == exist(obj.toolboxRoot, 'dir')
                rmdir(obj.toolboxRoot, 's');
            end
            
            if 7 == exist(obj.alternateRoot, 'dir')
                rmdir(obj.alternateRoot, 's');
            end
            
        end
    end
    
    methods (TestMethodTeardown)
        function restoreOriginalMatlabState(obj)
            path(obj.originalMatlabPath);
        end
    end
    
    methods (Test)
        function testLifecycle(obj)
            % declare toolbox configuration
            [config, expectedFiles, unexpectedFiles] = obj.createConfig();
            tbWriteConfig(config, 'configPath', obj.configPath);
            config = tbReadConfig('configPath', obj.configPath);
            
            % fetch toolboxes fresh (see setup method)
            results = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'reset', 'full');
            obj.sanityCheckResults(results, expectedFiles, unexpectedFiles);
            
            % fetch again should be safe
            results = tbDeployToolboxes(...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'reset', 'full');
            obj.sanityCheckResults(results, expectedFiles, unexpectedFiles);
        end
        
        function testAddOneAtATime(obj)
            % build up config file from scratch
            [config, expectedFiles, unexpectedFiles] = obj.createConfig();
            for tt = 1:numel(config)
                record = config(tt);
                results = tbAddToolbox( ...
                    'toolboxRoot', obj.toolboxRoot, ...
                    'configPath', obj.configPath, ...
                    'name', record.name, ...
                    'url', record.url, ...
                    'flavor', record.flavor, ...
                    'update', record.update, ...
                    'subfolder', record.subfolder, ...
                    'type', record.type);
                obj.sanityCheckResults(results, expectedFiles, unexpectedFiles);
            end
        end
        
        function testSubfolderPath(obj)
            % deploy just "subfolder-1", not "subfolder-2".
            testRepoUrl = 'https://github.com/ToolboxHub/sample-repo.git';
            result = tbAddToolbox( ...
                'toolboxRoot', obj.toolboxRoot, ...
                'configPath', obj.configPath, ...
                'name', 'subfolderOnly', ...
                'url', testRepoUrl, ...
                'subfolder', 'subfolder-1', ...
                'type', 'git');
            obj.assertEqual(result.status, 0);
            
            % should have subfolder-1 on the path
            inSubfolder1 = which('in-subfolder-1.txt');
            obj.assertNotEmpty(inSubfolder1);
            
            % should not have subfolder-2 on the path
            inSubfolder2 = which('in-subfolder-2.txt');
            obj.assertEmpty(inSubfolder2);
        end
        
        function testTwoSubfolderPaths(obj)
            % deploy "subfolder-1" and "subfolder-2", but not the root
            testRepoUrl = 'https://github.com/ToolboxHub/sample-repo.git';
            result = tbAddToolbox( ...
                'toolboxRoot', obj.toolboxRoot, ...
                'configPath', obj.configPath, ...
                'name', 'subfoldersOnly', ...
                'url', testRepoUrl, ...
                'subfolder', {'subfolder-1', 'subfolder-2'}, ...
                'type', 'git');
            obj.assertEqual(result.status, 0);
            
            % should have subfolder-1 on the path
            inSubfolder1 = which('in-subfolder-1.txt');
            obj.assertNotEmpty(inSubfolder1);
            
            % should have subfolder-2 on the path
            inSubfolder2 = which('in-subfolder-2.txt');
            obj.assertNotEmpty(inSubfolder2);
            
            % should have root folder on the path
            inRoot = which('master.txt');
            obj.assertEmpty(inRoot);
        end
        
        function testHook(obj)
            testRepoUrl = 'https://github.com/ToolboxHub/sample-repo.git';
            hookFolder = fullfile(obj.toolboxRoot, 'testHook');
            result = tbAddToolbox( ...
                'toolboxRoot', obj.toolboxRoot, ...
                'configPath', obj.configPath, ...
                'name', 'withHook', ...
                'url', testRepoUrl, ...
                'hook', ['mkdir ' hookFolder], ...
                'type', 'git');
            obj.assertEqual(result.status, 0);
            
            % should have created the "testHook" folder
            obj.assertEqual(exist(hookFolder, 'dir'), 7);
        end
        
        function testAlternateToolboxRoot(obj)
            % put odd-numbered toolboxes under an alternate root folder
            [config, expectedFiles, unexpectedFiles] = obj.createConfig();
            for tt = 1:2:numel(config)
                config(tt).toolboxRoot = obj.alternateRoot;
            end
            
            % fetch toolboxes
            results = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'reset', 'full');
            obj.sanityCheckResults(results, expectedFiles, unexpectedFiles);
            
            for tt = 1:2:numel(results)
                record = results(tt);
                strategy = record.strategy;
                
                % odd-numbered toolboxes should appear under alternate root
                [~, subfolder] = strategy.toolboxPath(obj.alternateRoot, record);
                alternatePath = fullfile(obj.alternateRoot, subfolder);
                obj.assertEqual(exist(alternatePath, 'dir'), 7);
                
                % and not under the standard root
                standardPath = fullfile(obj.toolboxRoot, subfolder);
                obj.assertEqual(exist(standardPath, 'dir'), 0);
            end
        end
        
        function testPathAppend(obj)
            [config, expectedFiles, unexpectedFiles] = obj.createConfig();
            [config.pathPlacement] = deal('append');
            results = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'reset', 'full');
            obj.sanityCheckResults(results, expectedFiles, unexpectedFiles);
            
            % toolboxes should appear after built-ins and in config order
            builtInFolder = toolboxdir('matlab');
            foldersToFind = cat(2, {builtInFolder}, {results.path});
            matlabPath = path();
            lastIndex = 0;
            for ff = 1:numel(foldersToFind)
                folder = foldersToFind{ff};
                folderIndices = strfind(matlabPath, folder);
                obj.assertTrue(all(folderIndices > lastIndex));
                lastIndex = max(folderIndices);
            end
        end
        
        function testPathPrepend(obj)
            [config, expectedFiles, unexpectedFiles] = obj.createConfig();
            [config.pathPlacement] = deal('prepend');
            results = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'reset', 'full');
            obj.sanityCheckResults(results, expectedFiles, unexpectedFiles);
            
            % toolboxes should appear before built-ins and in reverse order
            builtInFolder = toolboxdir('matlab');
            foldersToFind = cat(2, {builtInFolder}, {results.path});
            matlabPath = path();
            lastIndex = inf;
            for ff = 1:numel(foldersToFind)
                folder = foldersToFind{ff};
                folderIndices = strfind(matlabPath, folder);
                obj.assertTrue(all(folderIndices < lastIndex));
                lastIndex = min(folderIndices);
            end
        end
        
        function testOptionalToolbox(obj)
            % make the first record fail
            config = obj.createConfig();
            config(1).hook = 'error(''I am optional'')';
            
            % failure should break the deployment
            results = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'reset', 'full');
            obj.assertFalse(results(1).isOk);
            obj.assertEqual(results(1).message, 'I am optional');
            
            % now make it optional
            config(1).importance = 'optional';
            
            % failure should *not* break the deployment
            results = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'reset', 'full');
            obj.assertTrue(all(tbCollectField(results, 'isOk', 'template', [])));
            obj.assertEqual(results(1).message, 'I am optional');
        end
        
        function testAddPathAfterError(obj)
            % fetch toolboxes fresh
            [config, expectedFiles, unexpectedFiles] = obj.createConfig();
            results = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'reset', 'full');
            obj.sanityCheckResults(results, expectedFiles, unexpectedFiles);
            
            % fetch again but introduce an error
            config(1).hook = 'error(''Oops!'')';
            results = tbDeployToolboxes(...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'reset', 'full');
            obj.assertFalse(results(1).isOk);
            obj.assertEqual(results(1).message, 'Oops!');
            
            % despite error, should find config on the path
            expectedFiles = expectedFiles.(config(1).name);
            whichExpected = which(expectedFiles{1});
            obj.assertNotEmpty(whichExpected);
        end
        
        function testDoNotAddToPath(obj)
            % fetch toolboxes fresh
            [config, expectedFiles, unexpectedFiles] = obj.createConfig();
            results = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'reset', 'full', ...
                'addToPath', false);
            obj.assertTrue(all(tbCollectField(results, 'status', 'template', []) == 0));
            
            whichExpected = which('master.txt');
            obj.assertEmpty(whichExpected);
        end
        
        function testWithJsonSlashEscapes(obj)
            % make sure we can read JSON that includes slash escapes
            %   like "https:\/\/github.com\/ToolboxHub\/sample-repo.git"
            
            pathHere = fileparts(mfilename('fullpath'));
            configFile = fullfile(pathHere, 'fixture', 'with-slash-escapes.json');
            results = tbDeployToolboxes( ...
                'configPath', configFile, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'reset', 'full');
            obj.assertEqual(results.status, 0);
            
            whichExpected = which('master.txt');
            obj.assertNotEmpty(whichExpected);
        end
        
        function testWithoutJsonSlashEscapes(obj)
            % make sure we can read JSON that omits slash escapes
            %   like "https://github.com/ToolboxHub/sample-repo.git"
            
            pathHere = fileparts(mfilename('fullpath'));
            configFile = fullfile(pathHere, 'fixture', 'without-slash-escapes.json');
            results = tbDeployToolboxes( ...
                'configPath', configFile, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'reset', 'full');
            obj.assertEqual(results.status, 0);
            
            whichExpected = which('master.txt');
            obj.assertNotEmpty(whichExpected);
        end
        
    end
    
    methods
        function [config, expectedFiles, unexpectedFiles] = createConfig(obj)
            testRepoUrl = 'https://github.com/ToolboxHub/sample-repo.git';
            config = [ ...
                tbToolboxRecord('name', 'simple', 'url', testRepoUrl, 'type', 'git'), ...
                tbToolboxRecord('name', 'noUpdate', 'url', testRepoUrl, 'type', 'git', 'update', 'never'), ...
                tbToolboxRecord('name', 'withBranch', 'url', testRepoUrl, 'type', 'git', 'flavor', 'sampleBranch'), ...
                tbToolboxRecord('name', 'withTag', 'url', testRepoUrl, 'type', 'git', 'flavor', 'sampleTag'), ...
                tbToolboxRecord('name', 'withCommit', 'url', testRepoUrl, 'type', 'git', 'flavor', 'c1c57d6290f601b98f3dc0d73b0c5a3522165e31'), ...
                tbToolboxRecord('name', 'withSubfolder', 'url', testRepoUrl, 'type', 'git', 'subfolder', 'subfolder-1'), ...
                ];
            expectedFiles = struct( ...
                'simple', {{'master.txt'}}, ...
                'noUpdate', {{'master.txt'}}, ...
                'withBranch', {{'master.txt', 'branch.txt'}}, ...
                'withTag', {{'master.txt', 'tag.txt'}}, ...
                'withCommit', {{}}, ...
                'withSubfolder', {{'in-subfolder-1.txt'}});
            unexpectedFiles = struct( ...
                'simple', {{'branch.txt', 'tag.txt'}}, ...
                'noUpdate', {{'branch.txt', 'tag.txt'}}, ...
                'withBranch', {{'tag.txt'}}, ...
                'withTag', {{'branch.txt'}}, ...
                'withCommit', {{'master.txt', 'branch.txt', 'tag.txt'}}, ...
                'withSubfolder', {{'in-subfolder-2.txt'}});
        end
        
        function sanityCheckResults(obj, results, expectedFiles, unexpectedFiles)
            nToolboxes = numel(results);
            
            for tt = 1:nToolboxes
                result = results(tt);
                
                % status OK?
                obj.assertEqual(result.status, 0, ...
                    sprintf('command "%s" -> message "%s"', result.command, result.message));
                
                % toolbox with optional subfolder
                toolboxPath = tbToolboxPath(obj.toolboxRoot, result);
                if ~isempty(result.subfolder) && ischar(result.subfolder)
                    toolboxPath = fullfile(toolboxPath, result.subfolder);
                end
                
                % expected files present?
                expected = expectedFiles.(result.name);
                for ff = 1:numel(expected)
                    expectedFile = expected{ff};
                    expectedPath = fullfile(toolboxPath, expectedFile);
                    obj.assertEqual(exist(expectedPath, 'file'), 2, ...
                        sprintf('For toolbox "%s", expected file "%s" not found.', ...
                        result.name, expectedPath));
                    
                    whichFile = which(expectedFile);
                    obj.assertNotEmpty(whichFile, ...
                        sprintf('For toolbox "%s", expected file "%s" not on the Matlab path.', ...
                        result.name, expectedFile));
                end
                
                % unexpected files present?
                unexpected = unexpectedFiles.(result.name);
                for ff = 1:numel(unexpected)
                    unexpectedFile = unexpected{ff};
                    unexpectedPath = fullfile(toolboxPath, unexpectedFile);
                    obj.assertEqual(exist(unexpectedPath, 'file'), 0, ...
                        sprintf('For toolbox "%s", unexpected file "%s" was found.', ...
                        result.name, unexpectedFile));
                end
            end
        end
    end
end
