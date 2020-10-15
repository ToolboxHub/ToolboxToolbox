classdef Model < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        toolboxNames
        prefs
    end
    
    methods(Access = private)
        function s = getToolboxesString(~, toolboxNames)
            assert(iscell(toolboxNames))
            if length(toolboxNames) == 1
                s = ['''' toolboxNames{1} ''''];
            else
                x = join(toolboxNames, ''', ''');
                s = ['{''' x{1} '''}'];
            end
        end
    end
    
    methods
        function self = Model
            [~, self.toolboxNames] = tbGetToolboxNames;
            self.prefs = tbParsePrefs(tbGetPersistentPrefs);
        end
        
        function use(self, toolboxNames)
            tbUse(toolboxNames, self.prefs);
        end
        
        function copyToClipboard(self, toolboxNames)
            toolboxStr = self.getToolboxesString(toolboxNames);
            str = ['tbUse(' toolboxStr ');'];
            disp(['copy "' str '" to clipboard']);
            clipboard('copy', str);
        end
        
        function filteredToolboxNames = filterToolboxes(self, filterStr)
            if isempty(filterStr)
                % If filter string is empty, e.g after clearing the filter
                % edit box, the user most likely wants to see everything
                filterStr = '.*';
            end
            idx = ~cellfun(@isempty, regexpi(self.toolboxNames, filterStr));
            filteredToolboxNames = self.toolboxNames(idx);
        end
    end
end

