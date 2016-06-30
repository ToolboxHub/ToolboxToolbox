classdef TbSanityTest < matlab.unittest.TestCase
    % Test the Toolbox Toolbox against a contrived Githib repository.
    %
    % The contrived GitHub repository at
    % https://github.com/benjamin-heasly/sample-repo.git has and expected
    % branch, tag, and commit, each with some expected and unexpected
    % files.  These expectations are declared in the properties of this
    % class.
    %
    % The Toolbox Toolbox should be able to fetch each flavor of the
    % repository.  This test suite will verify the expected and unexpected
    % files.
    %
    % 2016 benjamin.heasly@gmail.com
    
    properties
        configPath = fullfile(tempdir(), 'toolbox-config.json');
        toolboxRoot = fullfile(tempdir(), 'toolboxes');
        originalMatlabPath;
    end
    
    methods (TestMethodSetup)
        function saveOriginalMatlabState(obj)
            obj.originalMatlabPath = path();
            tbResetMatlabPath('withSelf', true, 'withBuiltIn', true);
        end
        
        function cleanUpTempFiles(obj)
            if 2 == exist(obj.configPath, 'file')
                delete(obj.configPath);
            end
            
            if 7 == exist(obj.toolboxRoot, 'dir')
                rmdir(obj.toolboxRoot, 's');
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
                'restorePath', true);
            obj.sanityCheckResults(results, expectedFiles, unexpectedFiles);
            
            % fetch again should be sage
            results = tbDeployToolboxes(...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'restorePath', true);
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
                    'subfolder', record.subfolder);
                obj.sanityCheckResults(results, expectedFiles, unexpectedFiles);
            end
        end
        
        function testSubfolderPath(obj)
            % deploy just "subfolder-1", not "subfolder-2".
            testRepoUrl = 'https://github.com/benjamin-heasly/sample-repo.git';
            result = tbAddToolbox( ...
                'toolboxRoot', obj.toolboxRoot, ...
                'configPath', obj.configPath, ...
                'name', 'subfolderOnly', ...
                'url', testRepoUrl, ...
                'subfolder', 'subfolder-1');
            obj.assertEqual(result.status, 0);
            
            % should have subfolder-1 on the path
            inSubfolder1 = which('in-subfolder-1.txt');
            obj.assertNotEmpty(inSubfolder1);
            
            % should not have subfolder-2 on the path
            inSubfolder2 = which('in-subfolder-2.txt');
            obj.assertEmpty(inSubfolder2);
        end
        
        function testHook(obj)
            testRepoUrl = 'https://github.com/benjamin-heasly/sample-repo.git';
            hookFolder = fullfile(obj.toolboxRoot, 'testHook');
            result = tbAddToolbox( ...
                'toolboxRoot', obj.toolboxRoot, ...
                'configPath', obj.configPath, ...
                'name', 'withHook', ...
                'url', testRepoUrl, ...
                'hook', ['mkdir ' hookFolder]);
            obj.assertEqual(result.status, 0);
            
            % should have created the "testHook" folder
            obj.assertEqual(exist(hookFolder, 'dir'), 7);
        end
    end
    
    methods
        function [config, expectedFiles, unexpectedFiles] = createConfig(obj)
            testRepoUrl = 'https://github.com/benjamin-heasly/sample-repo.git';
            config = [ ...
                tbToolboxRecord('name', 'simple', 'url', testRepoUrl), ...
                tbToolboxRecord('name', 'noUpdate', 'url', testRepoUrl, 'update', 'never'), ...
                tbToolboxRecord('name', 'withBranch', 'url', testRepoUrl, 'flavor', 'sampleBranch'), ...
                tbToolboxRecord('name', 'withTag', 'url', testRepoUrl, 'flavor', 'sampleTag'), ...
                tbToolboxRecord('name', 'withCommit', 'url', testRepoUrl, 'flavor', 'c1c57d6290f601b98f3dc0d73b0c5a3522165e31'), ...
                tbToolboxRecord('name', 'withSubfolder', 'url', testRepoUrl, 'subfolder', 'subfolder-1'), ...
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
                
                % expected files present?
                expected = expectedFiles.(result.name);
                for ff = 1:numel(expected)
                    expectedFile = expected{ff};
                    expectedPath = fullfile(obj.toolboxRoot, result.name, result.flavor, result.subfolder, expectedFile);
                    obj.assertEqual(exist(expectedPath, 'file'), 2, ...
                        sprintf('For toolbox "%s", expected file "%s" not found.', ...
                        result.name, expectedPath));
                    
                    whichFile = which(expectedFile);
                    obj.assertNotEmpty(whichFile, ...
                        sprintf('For toolbox "%s", expected file "%s" not on the Matlab path.', ...
                        result.name, expectedFile));
                end
                
                % unexpected files not on Matlab path?
                unexpected = unexpectedFiles.(result.name);
                for ff = 1:numel(unexpected)
                    unexpectedFile = unexpected{ff};
                    unexpectedPath = fullfile(obj.toolboxRoot, result.name, result.flavor, result.subfolder, unexpectedFile);
                    obj.assertEqual(exist(unexpectedPath, 'file'), 0, ...
                        sprintf('For toolbox "%s", unexpected file "%s" was found.', ...
                        result.name, unexpectedFile));
                end
            end
        end
    end
end
