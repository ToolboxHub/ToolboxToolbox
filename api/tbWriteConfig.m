function configPath = tbWriteConfig(config, varargin)
% Write the given toolbox config struct to a file.
%
% The idea is to take the toolbox configuration struct we're working with
% and write it to a file for later.  When we write, we massage the given
% configuration into well-formed records.
%
% configPath = tbWriteConfig(config) write the given config struct to a file
% at the default location, and returns the full, absolute path to the
% written file.
%
% This function uses ToolboxToolbox shared parameters and preferences.  See
% tbParsePrefs().
%
% 2016 benjamin.heasly@gmail.com

prefs = tbParsePrefs(varargin{:});

parser = inputParser();
parser.addRequired('config', @isstruct);
parser.parse(config);
config = parser.Results.config;

%% Massage the given config into well-formed records.
nToolboxes = numel(config);
wellFormedRecords = cell(1, nToolboxes);
for tt = 1:nToolboxes
    record = config(tt);
    wellFormedRecords{tt} = tbToolboxRecord(record);
end
records = [wellFormedRecords{:}];

%% Write out to disk.
savejson('', records, prefs.configPath);
