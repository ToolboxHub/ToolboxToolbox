function [s, identifiers] = tbGetToolboxNames
%TBGETTOOLBOXNAMES Get struct containing the toolbox names
%
%  [namesStruct, identifiers] = tbGetToolboxNames()
%
%  OUTPUT
%    namesStruct: returns a struct where each field corresponds to a toolbox
% .               The field contains the toolbox name as a char array.
%                 The result is populated by parsing the configurations
%                 directory of the ToolboxRegistry. Subfolders are handled
%                 correctly.
%
%    identifiers: toolbox names as cell array of char
%
%  2019 Markus Leuthold (github@titlis.org)

prefs = tbParsePrefs(tbGetPersistentPrefs);
registryRoot = tbLocateToolbox(prefs.registry);
configRoot = fullfile(registryRoot, prefs.registry.subfolder);

[s, identifiers] = getNamesRecursively(struct, configRoot, configRoot, {});

function [s, identifiers] = getNamesRecursively(s, curPath, configRoot, identifiers)
dAll = dir(curPath);
d = dAll(~startsWith({dAll.name}, '.'));

for k = find([d.isdir])
    [curIdentifier, identifiers] = getNamesRecursively(...
        [], fullfile(d(k).folder, d(k).name), configRoot, identifiers);
    s.(d(k).name) = curIdentifier;
end

for k = find(~[d.isdir])
    %strip extension
    [~, name] = fileparts(d(k).name);
    
    %strip root
    base = erase(d(k).folder, configRoot);
    
    %delete slash at the beginning, if any
    base = regexprep(base, ['^\' filesep], '');
    
    identifier = fullfile(base, name);
    s.(matlab.lang.makeValidName(name)) = identifier;
    identifiers = [identifiers; identifier];
end

