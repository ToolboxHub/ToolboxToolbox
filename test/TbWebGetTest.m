classdef TbWebGetTest < matlab.unittest.TestCase
    % Test the Toolbox Toolbox against a contrived Githib repository.
    %
    % The contrived GitHub repository at
    % https://github.com/ToolboxHub/sample-repo.git has an expected
    % GitHub release named v0.1.
    %
    % The Toolbox Toolbox should be able to download regular and zip files
    % that are part of the release.
    %
    % 2016 benjamin.heasly@gmail.com
    
    properties
        zipUrl = 'https://github.com/ToolboxHub/sample-repo/archive/v0.1.zip';
        zipNoExtUrl = 'https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/59411/versions/1/download/zip';
        imageUrl = 'https://github.com/ToolboxHub/sample-repo/releases/download/v0.1/sample-download.jpg';
        configPath = fullfile(tempdir(), 'toolbox_config.json');
        toolboxRoot = fullfile(tempdir(), 'toolboxes');
        originalMatlabPath;
    end
    
    methods (TestMethodSetup)
        function saveOriginalMatlabState(obj)
            obj.originalMatlabPath = path();
            tbResetMatlabPath('reset', 'full');
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
        function testZipFile(obj)
            record = tbToolboxRecord( ...
                'type', 'webget', ...
                'name', 'zipFile', ...
                'url', obj.zipUrl);
            results = tbDeployToolboxes(tbGetPersistentPrefs, ...
                'config', record, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'reset', 'full');
            obj.assertEqual(results.status, 0);
            
            % zip should now be on the path
            zipFile = which('v0.1.zip');
            obj.assertEqual(exist(zipFile, 'file'), 2);
            
            % zip contents should now be on the path
            textFile = which('master.txt');
            obj.assertEqual(exist(textFile, 'file'), 2);
        end
        
        function testZipFileNoExtension(obj)
            record = tbToolboxRecord( ...
                'type', 'webget', ...
                'name', 'zipFile', ...
                'url', obj.zipNoExtUrl, ...
                'flavor', 'zip');
            results = tbDeployToolboxes(tbGetPersistentPrefs, ...
                'config', record, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'reset', 'full');
            obj.assertEqual(results.status, 0);
            
            % zip contents should now be on the path
            struct2xmlFile = which('struct2xml.m');
            obj.assertEqual(exist(struct2xmlFile, 'file'), 2);
        end
        
        function testImageFile(obj)
            % download an image file
            record = tbToolboxRecord( ...
                'type', 'webget', ...
                'name', 'imageFile', ...
                'url', obj.imageUrl);
            results = tbDeployToolboxes(tbGetPersistentPrefs, ...
                'config', record, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'reset', 'full');
            obj.assertEqual(results.status, 0);
            
            % image should now be on the path
            imageFile = which('sample-download.jpg');
            obj.assertEqual(exist(imageFile, 'file'), 2);
            
            % should be able to load the image
            imageData = imread(imageFile);
            obj.assertEqual(size(imageData), [491 736 3]);
        end
        
        function testUpdate(obj)
            % download an image file
            record = tbToolboxRecord( ...
                'type', 'webget', ...
                'name', 'update', ...
                'url', obj.imageUrl);
            results = tbDeployToolboxes(tbGetPersistentPrefs, ...
                'config', record, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'reset', 'full');
            obj.assertEqual(results.status, 0);
            
            % image should now be on the path
            imageFile = which('sample-download.jpg');
            obj.assertEqual(exist(imageFile, 'file'), 2);
            
            % delay to force updated file to have different time stamp
            pause(1);
            
            % update should replace the image with another copy
            obtainInfo = dir(imageFile);
            results = tbDeployToolboxes(tbGetPersistentPrefs, ...
                'config', record, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'reset', 'full', ...
                'update', 'asspecified');
            obj.assertEqual(results.status, 0);
            updateInfo = dir(imageFile);
            obj.assertGreaterThan(datenum(updateInfo.date), datenum(obtainInfo.date));
        end
        
        function testNoUpdate(obj)
            % download an image file
            record = tbToolboxRecord( ...
                'type', 'webget', ...
                'name', 'noUpdate', ...
                'url', obj.imageUrl, ...
                'update', 'never');
            results = tbDeployToolboxes(tbGetPersistentPrefs, ...
                'config', record, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'reset', 'full');
            obj.assertEqual(results.status, 0);
            
            % image should now be on the path
            imageFile = which('sample-download.jpg');
            obj.assertEqual(exist(imageFile, 'file'), 2);
            
            % delay to force updated file to have different time stamp
            pause(1);
            
            % update should have no effect on the image already downloaded
            obtainInfo = dir(imageFile);
            results = tbDeployToolboxes(tbGetPersistentPrefs, ...
                'config', record, ...
                'toolboxRoot', obj.toolboxRoot, ...
                'reset', 'full');
            obj.assertEqual(results.status, 0);
            updateInfo = dir(imageFile);
            obj.assertEqual(updateInfo.date, obtainInfo.date);
        end
    end
end
