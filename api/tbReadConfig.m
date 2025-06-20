function [config, configPath] = tbReadConfig(persistentPrefs, varargin)
% Read toolbox configuration from a file.
%
% The idea is to locate a toolbox configuration file on disk, and load it
% into Matlab so we can work with it.  When we read, we massage the
% configuration into well-formed records.
%
% [config, configPath] = tbReadConfig() reads a config struct from file at
% the default location.  Returns the config struct as well as the full,
% absolute path to the file that was read.
%
% This function uses ToolboxToolbox shared parameters and preferences.  See
% tbParsePrefs().
%
% 2016 benjamin.heasly@gmail.com

prefs = tbParsePrefs(persistentPrefs, varargin{:});
configPath = prefs.configPath;
config = [];

%% Read from Web?
if ~isempty(strfind(lower(configPath), 'http://')) ...
        || ~isempty(strfind(lower(configPath), 'https://'))
    
    tempFolder = fullfile(tempdir(), mfilename());
    if 7 ~= exist(tempFolder, 'dir')
        mkdir(tempFolder);
    end
    
    configUrl = configPath;
    [~, resourceBase, resourceExt] = fileparts(configUrl);
    configPath = fullfile(tempFolder, [resourceBase, resourceExt]);
    
    if prefs.online
        try
            configPath = websave(configPath, configUrl);
        catch
            configPath = '';
        end
    else
        configPath = '';
    end
end

%% Read from disk.
if 2 ~= exist(configPath, 'file')
    return;
end

try
    rawConfig = loadjson(configPath);
catch err
    disp(['cannot parse ' configPath])
    rethrow(err)
end

if ~isstruct(rawConfig) && ~iscell(rawConfig)
    return;
end

%% Massage the config into well-formed records.
nToolboxes = numel(rawConfig);
wellFormedRecords = cell(1, nToolboxes);
for tt = 1:nToolboxes
    if iscell(rawConfig)
        record = rawConfig{tt};
    else
        record = rawConfig(tt);
    end
    
    wellFormedRecords{tt} = tbToolboxRecord(record);
end
config = [wellFormedRecords{:}];

