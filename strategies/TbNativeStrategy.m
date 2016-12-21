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
    % The user must supply a special hook function for the toolbox record.
    % The name of the hook function must go in record.hook.  The function
    % should have no side-effects -- it must be safe to call it
    % repeatedly.  The function must take no arguments.  The function must
    % behave like this:
    %   - check whether the native dependency is present with appropriate
    %   calls to funcitons like ispc(), ismac(), isunix(), system(), etc.
    %   - on success, return a friendly message indicating that the
    %   dependency was found
    %   - on failure, throw an exception with a message that gives the user
    %   useful links and/or advice about how to obtain the missing
    %   dependency
    %
    % 2016-2017 benjamin.heasly@gmail.com
    
    methods
        function [command, status, message] = obtain(obj, record, toolboxRoot, toolboxPath)
            % check if the native dependency is present
            command = record.hook;
            fprintf('Checking for native dependency "%s" using function "%s":\n', ...
                record.name, command);
            
            try
                message = eval(command);
                status = 0;
                fprintf('  OK: "%s":\n', message);
            catch err
                message = err.message;
                status = -1;
                fprintf('  Not found.  Suggestion: "%s":\n\n', message);
            end
        end
        
        function [command, status, message] = update(obj, record, toolboxRoot, toolboxPath)
            [command, status, message] = obj.obtain(record, toolboxRoot, toolboxPath);
        end
    end
end
