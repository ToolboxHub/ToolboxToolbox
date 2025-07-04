classdef Controller < handle
    %MODEL MVC Controller class for tbGui()
    %
    %  SEE ALSO tbnewtoolbox.View, tbnewtoolbox.Model
    %
    %  2021 Markus Leuthold markus.leuthold@sonova.com
    
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
            self.view.init(self, self.model);
        end
        
        function plannedActions(self)
            [str, readyToCreate] = self.model.plannedActions(...
                self.view.getGithubUrl,...
                self.view.getGithubRepoName);
            self.view.setActionText(str);
            if readyToCreate
                self.view.setCreationState;
            end
        end

        function createToolbox(self)
            self.model.createToolbox(...
                self.view.getShortDescription, ...
                self.view.getSubfolder, ...
                self.view.getDependencies, ...
                self.view.getPathPlacement, ...
                self.view.getVisibility, ...
                self.model.actions);
        end

        function filteredToolboxNames = filterToolboxes(self, filterStr)
            filteredToolboxNames = self.model.filterToolboxes(filterStr);
        end
    end
end

