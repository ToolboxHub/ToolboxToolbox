classdef TbSvnTest < matlab.unittest.TestCase
    % Test the Toolbox Toolbox against a contrived Subversion repository.
    %
    % The contrived Subversion repository at
    % https://github.com/ToolboxHub/sample-repo.git has and expected
    % branch, tag, and revision, each with some expected and unexpected
    % files.
    %
    % The ToolboxToolbox should be able to fetch each flavor of the
    % repository.  This test suite will verify the expected and unexpected
    % files.
    %
    % 2016-2017 benjamin.heasly@gmail.com
    
    properties
        testRepoUrl = 'https://github.com/ToolboxHub/sample-repo.git';
        toolboxRoot = fullfile(tempdir(), 'toolboxes');
        originalMatlabPath;
    end
    
    methods (TestMethodSetup)
        function checkIfSvnPresent(testCase)
            [svnExists, ~, result] = TbSvnStrategy.assertSvnWorks();
            testCase.assumeTrue(svnExists, result);
        end
        
        function saveOriginalMatlabState(obj)
            obj.originalMatlabPath = path();
            tbResetMatlabPath('full');
        end
        
        function cleanUpTempFiles(obj)
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
        function testNotARepo(obj)
            config = tbToolboxRecord( ...
                'name', 'simple', ...
                'url', 'no such repo', ...
                'type', 'svn');
            
            result = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot);
            
            obj.assertNotEqual(result.status, 0);
        end
        
        function testTrunk(obj)
            config = tbToolboxRecord( ...
                'name', 'simple', ...
                'url', obj.testRepoUrl, ...
                'subfolder', 'trunk', ...
                'type', 'svn');
            result = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot);
            obj.assertEqual(result.status, 0);
            obj.sanityCheck(result, 'master.txt', 'branch.txt', 'master.txt');
            
            % update
            result = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot);
            obj.assertEqual(result.status, 0);
            obj.sanityCheck(result, 'master.txt', 'branch.txt', 'master.txt');
        end
        
        function testBranch(obj)
            config = tbToolboxRecord( ...
                'name', 'branch', ...
                'url', obj.testRepoUrl, ...
                'subfolder', 'branches/sampleBranch', ...
                'type', 'svn');
            result = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot);
            obj.assertEqual(result.status, 0);
            obj.sanityCheck(result, 'branch.txt', 'tag.txt', 'master.txt');
            
            % update
            result = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot);
            obj.assertEqual(result.status, 0);
            obj.sanityCheck(result, 'branch.txt', 'tag.txt', 'master.txt');
        end
        
        function testTag(obj)
            config = tbToolboxRecord( ...
                'name', 'tag', ...
                'url', obj.testRepoUrl, ...
                'subfolder', 'tags/sampleTag', ...
                'type', 'svn');
            result = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot);
            obj.assertEqual(result.status, 0);
            obj.sanityCheck(result, 'tag.txt', 'branch.txt', 'master.txt');
            
            % updatre
            result = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot);
            obj.assertEqual(result.status, 0);
            obj.sanityCheck(result, 'tag.txt', 'branch.txt', 'master.txt');
        end
        
        function testRevision(obj)
            config = tbToolboxRecord( ...
                'name', 'revision', ...
                'url', obj.testRepoUrl, ...
                'flavor', '2', ...
                'type', 'svn');
            result = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot);
            obj.assertEqual(result.status, 0);
            obj.sanityCheck(result, 'trunk/master.txt', 'branches/sampleBranch/branch.txt', 'master.txt');
            
            % update
            result = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot);
            obj.assertEqual(result.status, 0);
            obj.sanityCheck(result, 'trunk/master.txt', 'branches/sampleBranch/branch.txt', 'master.txt');
        end
        
        function testNotARevision(obj)
            config = tbToolboxRecord( ...
                'name', 'notARevision', ...
                'url', obj.testRepoUrl, ...
                'flavor', 'notARevision', ...
                'type', 'svn');
            result = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot);
            obj.assertNotEqual(result.status, 0);
        end
    end
    
    methods
        function sanityCheck(obj, result, expectedFile, unexpectedFile, fileOnPath)
            toolboxPath = tbLocateToolbox(result, ...
                'toolboxRoot', obj.toolboxRoot);
            
            expected = fullfile(toolboxPath, result.subfolder, expectedFile);
            obj.assertEqual(2, exist(expected, 'file'));
            
            unexpected = fullfile(toolboxPath, result.subfolder, unexpectedFile);
            obj.assertEqual(0, exist(unexpected, 'file'));
            
            whichFile = which(fileOnPath);
            obj.assertNotEmpty(whichFile);
        end
    end
end