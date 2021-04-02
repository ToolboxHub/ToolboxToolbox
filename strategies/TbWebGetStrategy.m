classdef TbWebGetStrategy < TbToolboxStrategy
    % Use HTTP GET to obtain a file.  May be a zip file to explode.
    %   see websave, unzip
    %
    % 2016 benjamin.heasly@gmail.com
    %
    % 04/01/21 dhb Add option 'CertificateFilename,'') via weboptions to websave
    %              command, in attempt to fix an SSL problem.
    
    methods
        function obj = TbWebGetStrategy(persistentPrefs)
            obj@TbToolboxStrategy(persistentPrefs);
        end
        
        function [command, status, message] = obtain(obj, record, toolboxRoot, toolboxPath)
            
            try 
                command = 'websave';
                [resourceUrl, resourceBase, resourceExt] = fileparts(record.url);
                
                % Matlab central has URLs that don't end in the zip
                % filename, but that none-the-less download a zip file.  Do
                % a little magic to deal with this case.
                if (~isempty(findstr(resourceUrl,'matlabcentral')) & strcmp(resourceBase,'zip'))
                    % Make the zip filename right
                    resourceBase = record.name;
                    resourceExt = '.zip';   
                    fileName = fullfile(toolboxPath,[resourceBase, resourceExt]);
                else
                    fileName = fullfile(toolboxPath, [resourceBase, resourceExt]);
                end
                
                command = 'mkdir';
                if 7 ~= exist(toolboxPath, 'dir')
                    mkdir(toolboxPath);
                end
                
                % Download
                options = weboptions('CertificateFilename','');
                fileName = websave(fileName, record.url, options);
                
                if strcmp(resourceExt, '.zip') || strcmp(record.flavor, 'zip')
                    command = 'unzip';
                    unzip(fileName, toolboxPath);
                end
                
                if strcmp(resourceExt, '.tgz') || strcmp(record.flavor, 'tgz')
                    command = 'untar';
                    untar(fileName, toolboxPath);
                end
                
                % Handle mltbx files.  At the moment, I am not doing any of
                % the install operations below, but they are here commented
                % out as one thing I tried. Currently the call to the
                % installToolbox routine happens in tbAddPath, which
                % actually makes more sense.
                %
                % What is here is a clearing out of a previously installed
                % version of the mltbx that we will later try to install.
                if (strcmp(resourceExt, '.mltbx') || strcmp(record.pathPlacement, 'mltbx'))
                    installedTbxs = matlab.addons.toolbox.installedToolboxes;
                    for tt = 1:length(installedTbxs)
                        if (strcmp(installedTbxs(tt).Name,record.name))
                            fprintf('In preparation for installing %s, uninstalling mltbx %s\n',...
                                record.name,installedTbxs(tt).Name);
                            matlab.addons.toolbox.uninstallToolbox(installedTbxs(tt));
                        end
                    end
                    % installed = matlab.addons.toolbox.installToolbox(fileName,true);
                    % installedPath = fullfile(userpath,'Add-Ons','Toolboxes',installed.Name);
                    % unix(['cp -r ' installedPath ' ' toolboxPath]);
                    % matlab.addons.toolbox.uninstallToolbox(installed);
                    % unix(['rm ' fileName]);
                end
                
            catch err
                status = -1;
                message = err.message;
                return;
            end
            
            % great!
            status = 0;
            message = 'download OK';
        end
        
        function [command, status, message] = update(obj, record, toolboxRoot, toolboxPath)
            if ~obj.prefs.online
                % toolbox already exists, but offline prevents update
                [command, status, message] = obj.skipUpdate();
                return;
            end
            
            [command, status, message] = obj.obtain(record, toolboxRoot, toolboxPath);
        end
        
        function [toolboxPath, displayName] = toolboxPath(obj, toolboxRoot, record)
  
            % Default: standard folder inside given toolboxRoot
            [toolboxPath, displayName] = tbToolboxPath(toolboxRoot, record);
             
            % Let's put matlabcentral files into their own directory
            [resourceUrl, resourceBase, resourceExt] = fileparts(record.url);
            if (~isempty(findstr(resourceUrl,'matlabcentral')) & strcmp(resourceBase,'zip'))
                % Put these toolboxes in a dir called matlabcentral
                [basePath,toolboxDir] = fileparts(toolboxPath);
                toolboxPath = fullfile(basePath,'matlabcentral',toolboxDir);
            end
            
        end
    end
end
