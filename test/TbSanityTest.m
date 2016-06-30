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
        expectedFiles = struct( ...
            'simple', {{'master.txt'}}, ...
            'withBranch', {{'master.txt', 'branch.txt'}}, ...
            'withTag', {{'master.txt', 'tag.txt'}}, ...
            'withCommit', {{}});
        unexpectedFiles = struct( ...
            'simple', {{'branch.txt', 'tag.txt'}}, ...
            'withBranch', {{'tag.txt'}}, ...
            'withTag', {{'branch.txt'}}, ...
            'withCommit', {{'master.txt', 'branch.txt', 'tag.txt'}});
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
            obj.createConfigFile();
            config = tbReadConfig('configPath', obj.configPath);
            
            % fetch toolboxes fresh (see setup method)
            results = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'restorePath', true);
            obj.sanityCheckResults(results);
            
            % fetch again should be sage
            results = tbDeployToolboxes(...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'restorePath', true);
            obj.sanityCheckResults(results);
        end
        
        function testAddOneAtATime(obj)
            % from scratch
            testRepoUrl = 'https://github.com/benjamin-heasly/sample-repo.git';
            results = tbAddToolbox( ...
                'toolboxRoot', obj.toolboxRoot, ...
                'configPath', obj.configPath, ...
                'name', 'simple', ...
                'url', testRepoUrl);
            obj.sanityCheckResults(results);
            
            results = tbAddToolbox( ...
                'toolboxRoot', obj.toolboxRoot, ...
                'configPath', obj.configPath, ...
                'name', 'withBranch', ...
                'url', testRepoUrl, ...
                'flavor', 'sampleBranch');
            obj.sanityCheckResults(results);
            
            results = tbAddToolbox( ...
                'toolboxRoot', obj.toolboxRoot, ...
                'configPath', obj.configPath, ...
                'name', 'withBranch', ...
                'name', 'withTag', ...
                'url', testRepoUrl, ...
                'flavor', 'sampleTag');
            obj.sanityCheckResults(results);
            
            results = tbAddToolbox( ...
                'toolboxRoot', obj.toolboxRoot, ...
                'configPath', obj.configPath, ...
                'name', 'withCommit', ...
                'url', testRepoUrl, ...
                'flavor', 'c1c57d6290f601b98f3dc0d73b0c5a3522165e31');
            obj.sanityCheckResults(results);
        end
    end
    
    methods
        function createConfigFile(obj)
            testRepoUrl = 'https://github.com/benjamin-heasly/sample-repo.git';
            config = [ ...
                tbToolboxRecord('name', 'simple', 'url', testRepoUrl), ...
                tbToolboxRecord('name', 'withBranch', 'url', testRepoUrl, 'flavor', 'sampleBranch'), ...
                tbToolboxRecord('name', 'withTag', 'url', testRepoUrl, 'flavor', 'sampleTag'), ...
                tbToolboxRecord('name', 'withCommit', 'url', testRepoUrl, 'flavor', 'c1c57d6290f601b98f3dc0d73b0c5a3522165e31'), ...
                ];
            tbWriteConfig(config, 'configPath', obj.configPath);
        end
        
        function sanityCheckResults(obj, results)
            nToolboxes = numel(results);
            
            for tt = 1:nToolboxes
                result = results(tt);
                
                % status OK?
                obj.assertEqual(result.status, 0, ...
                    sprintf('command "%s" -> message "%s"', result.command, result.message));
                
                % expected files present?
                expected = obj.expectedFiles.(result.name);
                for ff = 1:numel(expected)
                    expectedFile = expected{ff};
                    expectedPath = fullfile(obj.toolboxRoot, result.name, expectedFile);
                    obj.assertEqual(exist(expectedPath, 'file'), 2, ...
                        sprintf('For toolbox "%s", expected file "%s" not found.', ...
                        result.name, expectedPath));
                end
                
                % expected files on Matlab path?
                expected = obj.expectedFiles.(result.name);
                for ff = 1:numel(expected)
                    expectedFile = expected{ff};
                    whichFile = which(expectedFile);
                    obj.assertNotEmpty(whichFile, ...
                        sprintf('For toolbox "%s", expected file "%s" not on the Matlab path.', ...
                        result.name, expectedFile));
                end
                
                % unexpected files not presenet?
                unexpected = obj.expectedFiles.(result.name);
                for ff = 1:numel(unexpected)
                    unxpectedFile = unexpected{ff};
                    unexpectedPath = fullfile(obj.toolboxRoot, result.name, unxpectedFile);
                    obj.assertEqual(exist(unexpectedPath, 'file'), 2, ...
                        sprintf('For toolbox "%s", unexpected file "%s" was found.', ...
                        result.name, unexpectedPath));
                end
                
            end
        end
    end
end
