classdef TbLocalHookTest  < matlab.unittest.TestCase
    % Test the Toolbox Toolbox invoking local hook scripts.
    %
    % The Toolbox Toolbox should be able invoke local hook scripts that are
    % associated with toolboxes but exist outside the toolboxes.  It should
    % be able to create local hooks from a template provided by a toolbox.
    %
    % 2016 benjamin.heasly@gmail.com
    
    properties
        localFolder = fullfile(tempdir(), 'local_toolbox');
        localHookFolder = fullfile(tempdir(), 'local_hooks');
        localFileName = 'local_toolbox_file.txt';
        originalMatlabPath;
    end
    
    methods (TestMethodSetup)
        function saveOriginalMatlabState(obj)
            obj.originalMatlabPath = path();
            tbResetMatlabPath('full');
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
        
        function cleanUpLocalHooks(obj)
            if 7 == exist(obj.localHookFolder, 'dir')
                rmdir(obj.localHookFolder, 's');
            end
        end
    end
    
    methods (TestMethodTeardown)
        function restoreOriginalMatlabState(obj)
            path(obj.originalMatlabPath);
        end
    end
    
    methods (Test)
        function testExistingGoodHook(obj)
            % make the "good" hook exist in the local hooks folder
            pathHere = fileparts(mfilename('fullpath'));
            goodHook = fullfile(pathHere, 'fixture', 'goodHook.m');
            localHook = fullfile(obj.localHookFolder, 'local_toolbox.m');
            mkdir(obj.localHookFolder);
            copyfile(goodHook, localHook);
            
            % deplpoy should detect and run the good hook
            record = tbToolboxRecord( ...
                'type', 'local', ...
                'name', 'local_toolbox', ...
                'url', obj.localFolder);
            results = tbDeployToolboxes( ...
                'config', record, ...
                'reset', 'full', ...
                'localHookFolder', obj.localHookFolder);
            
            % good hook should have run without error
            obj.assertEqual(results.status, 0);
        end
        
        function testExistingBadHook(obj)
            % make the "bad" hook exist in the local hooks folder
            pathHere = fileparts(mfilename('fullpath'));
            badHook = fullfile(pathHere, 'fixture', 'badHook.m');
            localHook = fullfile(obj.localHookFolder, 'local_toolbox.m');
            mkdir(obj.localHookFolder);
            copyfile(badHook, localHook);
            
            % deplpoy should detect and run the bad hook
            record = tbToolboxRecord( ...
                'type', 'local', ...
                'name', 'local_toolbox', ...
                'url', obj.localFolder);
            results = tbDeployToolboxes( ...
                'config', record, ...
                'reset', 'full', ...
                'localHookFolder', obj.localHookFolder);
            
            % bad hook should throw an error
            obj.assertNotEqual(results.status, 0);
            obj.assertEqual(results.message, 'I am not a nice hook.');
        end
        
        function testTemplateGoodHook(obj)
            % make the "good" hook exist in the toolbox folder
            pathHere = fileparts(mfilename('fullpath'));
            goodHook = fullfile(pathHere, 'fixture', 'goodHook.m');
            copyfile(goodHook, obj.localFolder);
            
            % deplpoy should detect and run the good hook
            record = tbToolboxRecord( ...
                'type', 'local', ...
                'name', 'local_toolbox', ...
                'url', obj.localFolder, ...
                'localHookTemplate', 'goodHook.m');
            results = tbDeployToolboxes( ...
                'config', record, ...
                'reset', 'full', ...
                'localHookFolder', obj.localHookFolder);
            
            % good hook should have run without error
            obj.assertEqual(results.status, 0);
        end
        
        function testTemplateBadHook(obj)
            % make the "bad" hook exist in the toolbox folder
            pathHere = fileparts(mfilename('fullpath'));
            badHook = fullfile(pathHere, 'fixture', 'badHook.m');
            copyfile(badHook, obj.localFolder);
            
            % deplpoy should detect and run the bad hook
            record = tbToolboxRecord( ...
                'type', 'local', ...
                'name', 'local_toolbox', ...
                'url', obj.localFolder, ...
                'localHookTemplate', 'badHook.m');
            results = tbDeployToolboxes( ...
                'config', record, ...
                'reset', 'full', ...
                'localHookFolder', obj.localHookFolder);
            
            % bad hook should throw an error
            obj.assertNotEqual(results.status, 0);
            obj.assertEqual(results.message, 'I am not a nice hook.');
        end
        
        function testTemplateHookMissing(obj)
            % try to detect and run a hook that doesn't exist
            record = tbToolboxRecord( ...
                'type', 'local', ...
                'name', 'local_toolbox', ...
                'url', obj.localFolder, ...
                'localHookTemplate', 'IAmNotAHook.m');
            results = tbDeployToolboxes( ...
                'config', record, ...
                'reset', 'full', ...
                'localHookFolder', obj.localHookFolder);
            
            % missing hook should be skipped
            obj.assertEqual(results.status, 0);
        end
        
        function testHookInIncludeRecord(obj)
            % run an existing local hook 
            % even if it comes from an "include" record
            % use the "bad" hook so that we know that it was run
            pathHere = fileparts(mfilename('fullpath'));
            badHook = fullfile(pathHere, 'fixture', 'badHook.m');
            localHook = fullfile(obj.localHookFolder, 'include_record.m');
            mkdir(obj.localHookFolder);
            copyfile(badHook, localHook);
            
            % deplpoy should detect and run the bad hook
            record = tbToolboxRecord( ...
                'type', 'include', ...
                'name', 'include_record');
            [~, included] = tbDeployToolboxes( ...
                'config', record, ...
                'reset', 'full', ...
                'localHookFolder', obj.localHookFolder);
            
            % bad hook should throw an error
            obj.assertNotEqual(included.status, 0);
            obj.assertEqual(included.message, 'I am not a nice hook.');
        end
    end
end
