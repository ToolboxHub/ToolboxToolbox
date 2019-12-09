classdef TbHubTest < matlab.unittest.TestCase
    % Test the ToolboxToolbox against the public ToolboxHub.
    %
    % The Toolbox Toolbox should be able to find a public toolbox
    % configuration by name and deploy it.
    %
    % 2016 benjamin.heasly@gmail.com
    
    properties
        toolboxRoot = fullfile(tempdir(), 'toolboxes');
        originalMatlabPath;
    end
    
    methods (TestMethodSetup)
        function saveOriginalMatlabState(obj)
            obj.originalMatlabPath = path();
            tbResetMatlabPath('reset', 'full');
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
        function testSampleRepo(obj)
            whichSampleFile = which('master.txt');
            obj.assertEmpty(whichSampleFile);
            
            results = tbDeployToolboxes(tbGetPersistentPrefs, ...
                'config', tbToolboxRecord('name', 'sample-repo'), ...
                'toolboxRoot', obj.toolboxRoot);
            obj.assertSize(results, [1 1]);
            obj.assertEqual(results.status, 0);
            
            whichSampleFile = which('master.txt');
            obj.assertNotEmpty(whichSampleFile);
        end
        
        function testShorthand(obj)
            whichSampleFile = which('master.txt');
            obj.assertEmpty(whichSampleFile);
            
            results = tbDeployToolboxes(tbGetPersistentPrefs, ...
                'registered', {'sample-repo', 'sample-repo', 'sample-repo'}, ...
                'toolboxRoot', obj.toolboxRoot);
            obj.assertSize(results, [1 1]);
            obj.assertEqual(results.status, 0);
            
            whichSampleFile = which('master.txt');
            obj.assertNotEmpty(whichSampleFile);
        end
        
    end
end
