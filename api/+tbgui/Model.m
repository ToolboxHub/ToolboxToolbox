classdef Model < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        toolboxNames
        prefs
    end
    
    methods
        function self = Model
            [~, self.toolboxNames] = tbGetToolboxNames;
            self.prefs = tbParsePrefs(tbGetPersistentPrefs);
        end
        
        function use(self, toolboxName)
            tbUse(toolboxName, self.prefs);
        end
        
        function copyToClipboard(~, toolboxName)
            str = ['tbUse(''' toolboxName ''');'];
            disp(['copy "' str '" to clipboard']);
            clipboard('copy', str);
        end
        
        function filteredToolboxNames = filterToolboxes(self, filterStr)
            idx = ~cellfun(@isempty, regexpi(self.toolboxNames, filterStr));
            filteredToolboxNames = self.toolboxNames(idx);
        end
    end
end

