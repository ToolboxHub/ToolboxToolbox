classdef Controller < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        model
        view
    end
    
    methods
        function self = Controller(model, view)
            self.model = model;
            self.view = view;
            self.init;
        end
        
        function init(self)
            self.view.setToolboxNames(self.model.toolboxNames);
            self.view.setChangeDirectoryDropDown(self.model.prefs.cdToFolder);
            self.view.setResetDropDown(self.model.prefs.reset);
        end
        
        function useAndClose(self, toolboxNames)
            disp("selected: " + join(toolboxNames, ', '));
            self.model.use(toolboxNames);
            delete(self.view)
        end
        
        function copyToClipboardAndClose(self, selectedToolbox)
            self.model.copyToClipboard(selectedToolbox);
            delete(self.view)
        end
        
        function filteredToolboxNames = filterToolboxes(self, filterStr)
            filteredToolboxNames = self.model.filterToolboxes(filterStr);
        end
    end
end

