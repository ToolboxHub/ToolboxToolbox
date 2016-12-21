classdef TbNativeStrategy < TbToolboxStrategy
    % Check for native system dependencies.
    %
    % TbNativeStrategy checks for native system dependencies, such as
    % shared libraries that are installed by apt-get, homebrew, etc.
    % TbNativeStrategy can't actually install these dependencies, but it is
    % still useful:
    %   - It gives a way to declare and document the depenencies as part of
    %   the toolbox configuration struct/JSON.
    %   - It gives a way to "fail fast" and print a useful message at
    %   toolbox deployment time, as opposed to waiting for an obscure error
    %   to crop up later on.
    %
    % The way it works, is the user must supply a special hook for the
    % toolbox record.  This should be the name of a function in the
    % toolbox.  This function must return 3 values:
    %   - a status code indicating whether the native dependency was
    %   found -- 0 -> success, non-zero -> failure
    %   - a message indicating success or failure, such as the result
    %   returned from system()
    %   - on failure, useful links and/or advice to the user about how to
    %   obtain the missing dependency -- may be empty on success
    %
    % 2016-2017 benjamin.heasly@gmail.com
    
    methods
        function [command, status, message] = obtain(obj, record, toolboxRoot, toolboxPath)
            % check if the native dependency is present
            command = record.hook;
            fprintf('Checking for native dependency "%s" using function "%s":\n', ...
                record.name, command);
            [status, message, advice] = eval(command);
            
            % try to display useful messages
            if 0 == status
                fprintf('  OK: "%s":\n', message);
            else
                fprintf('  Not found: "%s":\n\n', message);
                fprintf('  Suggestion: "%s":\n\n', advice);
            end
        end
        
        function [command, status, message] = update(obj, record, toolboxRoot, toolboxPath)
            [command, status, message] = obj.obtain(record, toolboxRoot, toolboxPath);
        end
    end
end
