classdef TbLocalTest  < matlab.unittest.TestCase
    % Test the Toolbox Toolbox against a local toolbox.
    %
    % The Toolbox Toolbox should be able to manage the matlab path for
    % files that exist at any local path.
    %
    % 2016 benjamin.heasly@gmail.com
    
    properties
        localFolder = fullfile(tempdir(), 'local-toolbox');
        localFileName = 'local-toolbox-file.txt';
        originalMatlabPath;
    end
    
    methods (TestMethodSetup)
        function saveOriginalMatlabState(obj)
            obj.originalMatlabPath = path();
            tbResetMatlabPath('reset', 'full');
        end
        
        function copyFixture(obj)
            % copy known file to a temp "toolbox", not on the path
            if 7 == exist(obj.localFolder, 'dir')
                rmdir(obj.localFolder, 's');
            end
            mkdir(obj.localFolder);
            
            pathHere = fileparts(mfilename('fullpath'));
            fixtureFile = fullfile(pathHere, 'fixture', 'local-file.txt');
            tempFile = fullfile(obj.localFolder, obj.localFileName);
            copyfile(fixtureFile, tempFile);
        end
        
    end
    
    methods (TestMethodTeardown)
        function restoreOriginalMatlabState(obj)
            path(obj.originalMatlabPath);
        end
    end
    
    methods (Test)
        function testLocalFile(obj)
            % local file should not be on path yet
            localFile = which(obj.localFileName);
            obj.assertEmpty(localFile);
            
            record = tbToolboxRecord( ...
                'type', 'local', ...
                'name', 'local-toolbox', ...
                'url', obj.localFolder);
            results = tbDeployToolboxes(tbGetPersistentPrefs, ...
                'config', record, ...
                'reset', 'full');
            obj.assertEqual(results.status, 0);
            
            % now the local file should be on the path
            localFile = which(obj.localFileName);
            obj.assertEqual(exist(localFile, 'file'), 2);
        end
        
        function testFileUrlScheme(obj)
            % local file should not be on path yet
            localFile = which(obj.localFileName);
            obj.assertEmpty(localFile);
            
            record = tbToolboxRecord( ...
                'type', 'local', ...
                'name', 'local-toolbox', ...
                'url', ['file://' obj.localFolder]);
            results = tbDeployToolboxes(tbGetPersistentPrefs, ...
                'config', record, ...
                'reset', 'full');
            obj.assertEqual(results.status, 0);
            
            % now the local file should be on the path
            localFile = which(obj.localFileName);
            obj.assertEqual(exist(localFile, 'file'), 2);
        end
        
        function testMissingFile(obj)
            record = tbToolboxRecord( ...
                'type', 'local', ...
                'name', 'local-toolbox', ...
                'url', fullfile(tempdir(), 'no-such-folder'));
            results = tbDeployToolboxes(tbGetPersistentPrefs, ...
                'config', record, ...
                'reset', 'full');
            
            % should fail on missing toolbox
            obj.assertNotEqual(results.status, 0);
        end
    end
end
