classdef TbRequirementHookTest < matlab.unittest.TestCase
    % Test the requiremetHook field for finding system dependencies.
    %
    % The ToolboxToolbox should be able to determine if system requirements
    % are present, and "fail fast" at deployment time if not.
    %
    % 2016-2017 benjamin.heasly@gmail.com
    
    properties
        testRepoUrl = 'https://github.com/ToolboxHub/sample-repo.git';
        toolboxRoot = fullfile(tempdir(), 'toolboxes');
        originalMatlabPath;
    end
    
    methods (TestMethodSetup)
        function checkIfGitPresent(testCase)
            [status, result] = system('git --version');
            gitExists = 0 == status;
            testCase.assumeTrue(gitExists, result);
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
        function testRequirementPresent(obj)
            config = tbToolboxRecord( ...
                'name', 'simple', ...
                'url', obj.testRepoUrl, ...
                'requirementHook', 'TbRequirementHookTest.checkForGit', ...
                'type', 'git');
            result = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot);
            obj.assertEqual(result.status, 0);
        end
        
        function testRequirementMissing(obj)
            config = tbToolboxRecord( ...
                'name', 'simple', ...
                'url', obj.testRepoUrl, ...
                'requirementHook', 'TbRequirementHookTest.checkForNoSuchThing', ...
                'type', 'git');
            result = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot);
            obj.assertNotEqual(result.status, 0);
        end
        
        function testWrongHookSignature(obj)
            config = tbToolboxRecord( ...
                'name', 'simple', ...
                'url', obj.testRepoUrl, ...
                'requirementHook', 'TbRequirementHookTest.wrongSignature', ...
                'type', 'git');
            result = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot);
            obj.assertNotEqual(result.status, 0);
        end
        
        function testHookMissing(obj)
            config = tbToolboxRecord( ...
                'name', 'simple', ...
                'url', obj.testRepoUrl, ...
                'requirementHook', 'thisIsNotAHook', ...
                'type', 'git');
            result = tbDeployToolboxes( ...
                'config', config, ...
                'toolboxRoot', obj.toolboxRoot);
            obj.assertNotEqual(result.status, 0);
        end
    end
    
    methods (Static)
        function [status, result, advice] = checkForGit()
            [status, result] = system('git --version');
            advice = 'Please install Git (https://git-scm.com/)';
        end
        
        function [status, result, advice] = checkForNoSuchThing()
            [status, result] = system('noSuchThing --version');
            advice = 'Sorry, there is no such thing!';
        end
        
        function wrongSignature()
            disp('This function has the wrong signature!');
        end
    end
end
