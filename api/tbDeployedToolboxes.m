function toolboxNames = tbDeployedToolboxes(toolboxNames, cmd)
% TBDEPLOYEDTOOLBOXES Check if toolbox was already deployed previously
%
%    deployedToolboxNames = tbDeployedToolboxes()
%       return cell of toolbox names which are already deployed
%
%    deployedToolboxNames = tbDeployedToolboxes(toolboxNames, 'append')
%       Add <toolboxNames> to the list of deployed toolboxes
%
%    deployedToolboxNames = tbDeployedToolboxes(toolboxNames, 'reset')
%       Set only <toolboxNames> as list of deployed toolboxes
%
%    deployedToolboxNames = tbDeployedToolboxes(toolboxNames, 'remove')
%       Remove <toolboxNames> from list of deployed toolboxes
%
%    toolboxNames = tbDeployedToolboxes
%       Get all deployed toolbox names
%
%    This only works as long as packages are deployed by tbUse() and the
%    Matlab path is not modified manually


% A "clear all" command has no effect on the matlab path. Therefore make
% sure TOOLBOXES is never cleared during a Matlab session
mlock

persistent TOOLBOXES
if isempty(TOOLBOXES)
    TOOLBOXES = {};
end

if nargout == 0
    % write
    
    if ischar(toolboxNames)
        toolboxNames = {toolboxNames};
    end
    
    if isempty(toolboxNames)
        toolboxNames = {};
    end
    
    switch cmd
        case 'append'
            TOOLBOXES = [TOOLBOXES reshape(toolboxNames, 1, [])];
            
        case 'reset'
            % overwrite
            TOOLBOXES = reshape(toolboxNames, 1, []);
            
        case 'remove'
            TOOLBOXES = setdiff(TOOLBOXES, toolboxNames);
            
        otherwise
            error('wrong command')
    end
    
else
    % read
    toolboxNames = TOOLBOXES;
end