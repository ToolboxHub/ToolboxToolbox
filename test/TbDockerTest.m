classdef TbDockerTest < matlab.unittest.TestCase
    % Test the ToolboxToolbox against DockerHub
    %
    % The ToolboxToolbox should be able to pull down an image from Docker
    % Hub and detect whether it's already present.
    %
    % This test assumes Docker is installed and useable by Matlab without
    % sudo.  This means the Matlab is in the docker group, or similar.
    %
    % 2016 benjamin.heasly@gmail.com
    
    properties
        % aline is a public Linux base image, tiny and quick to test with
        imageName = 'alpine';
        imageTag = 'latest';
    end
    
    methods (TestMethodSetup)
        
        function checkIfServerPresent(testCase)
            [dockerExists, ~, result] = TbDockerStrategy.dockerExists();
            testCase.assumeTrue(dockerExists, result);
        end
        
        function cleanUpTestImage(obj)
            command = ['docker rmi --force ' obj.imageName];
            [status, result] = tbSystem(command);
        end
    end
    
    methods (Test)
        function testPullSimpleImageName(obj)
            record = tbToolboxRecord( ...
                'type', 'docker', ...
                'name', 'alpine', ...
                'url', obj.imageName);
            
            strategy = tbChooseStrategy(record);
            isPresent = strategy.checkIfPresent(record, '', '');
            obj.assertFalse(isPresent);
            
            results = tbDeployToolboxes('config', record);
            obj.assertEqual(results.status, 0);
            
            isPresent = strategy.checkIfPresent(record, '', '');
            obj.assertTrue(isPresent);
        end
        
        function testPullTaggedImageName(obj)
            record = tbToolboxRecord( ...
                'type', 'docker', ...
                'name', 'alpine', ...
                'url', obj.imageName, ...
                'falvor', obj.imageTag);
            
            strategy = tbChooseStrategy(record);
            isPresent = strategy.checkIfPresent(record, '', '');
            obj.assertFalse(isPresent);
            
            results = tbDeployToolboxes('config', record);
            obj.assertEqual(results.status, 0);
            
            isPresent = strategy.checkIfPresent(record, '', '');
            obj.assertTrue(isPresent);
        end
    end
end
