classdef TbNativeTest < matlab.unittest.TestCase
    % Test the TbNativeStrategy for finding system dependencies.
    %
    % The ToolboxToolbox should be able to determine if required native
    % system dependencies are present, and "fail fast" at deployment time
    % if missing.
    %
    % 2016-2017 benjamin.heasly@gmail.com
    
    methods (TestMethodSetup)
        function checkIfGitPresent(testCase)
            [status, result] = system('git --version');
            gitExists = 0 == status;
            testCase.assumeTrue(gitExists, result);
        end
    end
    
    methods (Test)
        function testDependencyPresent(obj)
            config = tbToolboxRecord( ...
                'name', 'git', ...
                'type', 'native', ...
                'hook', 'TbNativeTest.checkForGit');
            result = tbDeployToolboxes('config', config);
            obj.assertEqual(result.status, 0);
        end
        
        function testDependencyMissing(obj)
            config = tbToolboxRecord( ...
                'name', 'noSuchThing', ...
                'type', 'native', ...
                'hook', 'TbNativeTest.checkForNoSuchThing');
            result = tbDeployToolboxes('config', config);
            obj.assertNotEqual(result.status, 0);
        end
    end
    
    methods (Static)
        function result = checkForGit()
            [status, result] = system('git --version');
            assert(0 == status, 'Please install Git (https://git-scm.com/)');
        end
        
        function result = checkForNoSuchThing()
            [status, result] = system('noSuchThing --version');
            assert(0 == status, 'I''m sorry but there''s no such thing!');
        end
    end
end
