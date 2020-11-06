function found = tbFindToolbox(str)
%TBFINDTOOLBOX Find toolbox based on regex search pattern
%  found = tbFindToolbox(regexStr)
[~, identifiers] = tbGetToolboxNames;
idx = ~cellfun(@isempty, regexpi(identifiers, str, 'match'));
found = identifiers(idx);

