classdef TbToolboxStrategy < handle
    % Abstract template for how to obtain/update a type of toolbox.
    %
    % Outlines the requirements for obtaining and updating a toolbox.
    % Specific implementations will fill in specific details.  For example,
    % the Git implementation will decide that obtaining a toolbox requires
    % a "git clone", and that updating a toolbox requires a "git pull".
    %
    % This abstract template will make it easy to define new types of
    % toolbox that we can handle and drop them in.  It will also let users
    % define their own secret, awesome types of toolbox without having to
    % muck around in the Toolbox Toolbox code.
    %
    % 2016 benjamin.heasly@gmail.com
    
    properties
        prefs = tbParsePrefs();
    end
    
    methods (Abstract)
        [command, status, message] = obtain(obj, record, toolboxRoot, toolboxPath);
        [command, status, message] = update(obj, record, toolboxRoot, toolboxPath);
    end
    
    methods
        function [toolboxPath, displayName] = toolboxPath(obj, toolboxRoot, record)
            % default: standard folder inside given toolboxRoot
            [toolboxPath, displayName] = tbToolboxPath(toolboxRoot, record);
        end
        
        function isPresent = checkIfPresent(obj, record, toolboxRoot, toolboxPath)
            % default: is there a non-empty folder present?
            isPresent = 7 == exist(toolboxPath, 'dir') && 2 < numel(dir(toolboxPath));
        end
        
        function toolboxPath = addToPath(obj, record, toolboxPath)
            tbAddToPath(toolboxPath, 'pathPlacement', record.pathPlacement);
        end
        
        function flavor = detectFlavor(obj, record)
            % default: just report the original declared flavor
            flavor = record.flavor;
        end
        
        function [command, status, message] = skipUpdate(obj)
            status = 0;
            command = 'skipUpdate()';
            message = 'Proceeding without update.';
            if (obj.prefs.verbose) fprintf('Proceeding without update.\n'); end
        end
    end
end
