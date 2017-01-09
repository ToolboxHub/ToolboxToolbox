classdef TbInstalledTest  < matlab.unittest.TestCase
    % Test ToolboxToolbox against installed Matlab toolboxes.
    %
    % ToolboxToolbox should be able to manage the matlab path for installed
    % Matlab toolboxes.
    %
    % 2016 benjamin.heasly@gmail.com
    
    properties
        originalMatlabPath;
    end
    
    methods (TestMethodSetup)
        function saveOriginalMatlabState(obj)
            obj.originalMatlabPath = path();
            tbResetMatlabPath('reset', 'full');
        end
    end
    
    methods (TestMethodTeardown)
        function restoreOriginalMatlabState(obj)
            path(obj.originalMatlabPath);
        end
    end
    
    methods (Test)
        function testExcludeAndRestore(obj)
            % find an installed function
            %   so we need imageprocessing installed do this test
            originalImageInfo = which('imageinfo');
            obj.assertEqual(exist(originalImageInfo, 'file'), 2);
            
            % exclude it from the path
            tbResetMatlabPath('reset', 'no-matlab');
            whichImageInfo = which('imageinfo');
            obj.assertEmpty(whichImageInfo);
            
            % return it to the path
            record = tbToolboxRecord( ...
                'type', 'installed', ...
                'name', 'images');
            results = tbDeployToolboxes( ...
                'config', record, ...
                'reset', 'no-matlab');
            obj.assertEqual(results.status, 0);
            whichImageInfo = which('imageinfo');
            obj.assertEqual(whichImageInfo, originalImageInfo);
        end
        
        function testExcludeNoRestore(obj)
            % find an installed function
            %   so we need imageprocessing installed do this test
            originalImageInfo = which('imageinfo');
            obj.assertEqual(exist(originalImageInfo, 'file'), 2);
            
            % exclude it from the path
            tbResetMatlabPath('reset', 'no-matlab');
            whichImageInfo = which('imageinfo');
            obj.assertEmpty(whichImageInfo);
            
            % deploy but don't add to the path!
            record = tbToolboxRecord( ...
                'type', 'installed', ...
                'name', 'images', ...
                'pathPlacement', 'none');
            results = tbDeployToolboxes( ...
                'config', record, ...
                'reset', 'no-matlab');
            obj.assertEqual(results.status, 0);
            whichImageInfo = which('imageinfo');
            obj.assertEmpty(whichImageInfo);
        end
    end
end
