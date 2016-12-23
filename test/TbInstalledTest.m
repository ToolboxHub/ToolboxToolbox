classdef TbInstalledTest  < matlab.unittest.TestCase
    % Test the Toolbox Toolbox against installed Matlab toolboxes.
    %
    % The Toolbox Toolbox should be able to manage the matlab path built-in
    % matlab toolboxes
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
        function testCoreBuiltins(obj)
            % find an installed function
            %   so we need imageprocessing installed do this test
            whichImageinfo = which('imageinfo');
            obj.assertEqual(exist(whichImageinfo, 'file'), 2);
            
            % exclude it from the path
            tbResetMatlabPath('reset', 'no-matlab');
            whichImageinfo = which('imageinfo');
            obj.assertEqual(exist(whichImageinfo, 'file'), 0);
            
            % return it to the path
            record = tbToolboxRecord( ...
                'type', 'installed', ...
                'name', 'images');
            results = tbDeployToolboxes( ...
                'config', record, ...
                'reset', 'no-matlab');
            obj.assertEqual(results.status, 0);
            whichImageinfo = which('imageinfo');
            obj.assertEqual(exist(whichImageinfo, 'file'), 2);
        end
    end
end
