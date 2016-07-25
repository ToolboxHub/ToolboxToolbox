classdef TbIncludeStrategy < TbToolboxStrategy
    % Take transitive closure of "include" records.
    %
    % TbIncludeStrategy is a special-case strategy.  It is not supposed to
    % be used in the normal way with obatin/update.  In fact, these
    % operations are errors.
    %
    % Instead, this strategy inspects a given config and transitively
    % resolves additional records indicated by "inluced" records.  The
    % result is one big, fat, flat config which closes over the "includes".
    % This simplifies subsequent deploys.  It also gives us a chance to
    % prevent "include" loops.
    %
    % Also, we want included configs to be treated the same as
    % other configs.  In order for tbDeployToolboxes to do this
    % correctly, we need to use the same values for parameters like
    % toolboxRoot.  The obtain and update methods would not be able to see
    % these values, so we'd get unexpected default behavior for includes.
    %
    % Also, we don't care to store the "include" config itself in the
    % toolboxes folder.  What we really want to store are the included
    % toolboxes.
    %
    % 2016 benjamin.heasly@gmail.com
    
    methods
        function [command, status, message] = obtain(obj, record, toolboxRoot, toolboxPath)
            error('"include" record should have been resolved to another type.');
        end
        
        function [command, status, message] = update(obj, record, toolboxRoot, toolboxPath)
            error('"include" record should have been resolved to another type.');
        end
        
        function [toolboxPath, displayName] = toolboxPath(obj, toolboxRoot, record, varargin)
            error('"include" record should have been resolved to another type.');
        end
    end
    
    methods (Static)
        % Iterate the given config, append new records as they come.
        function config = resolveIncludedConfigs(config)
            cc = 1;
            while cc <= numel(config)
                record = config(cc);
                if strcmp(record.type, 'include')
                    newConfig = tbReadConfig('configPath', record.url)
                    config = TbIncludeStrategy.appendMissingConfig(config, newConfig);
                end
                cc = cc + 1;
            end
            
            % trim out the "includes" that we already resolved
            isInclude = strcmp({config.type}, 'include');
            config = config(~isInclude);
        end
        
        % Doesn the given config contains a record with the given name?
        function config = appendMissingConfig(config, newConfig)
            isMissing = ~ismember({newConfig.name}, {config.name});
            config = cat(2, config, newConfig(isMissing));
        end
    end
end
