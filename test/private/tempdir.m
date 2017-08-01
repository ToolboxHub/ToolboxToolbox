function dirPath = tempdir()
% overriden matlab temdir to genearted directory name with white space

functions = which('tempdir', '-all');
builtinTempDir = functions{end};
run(builtinTempDir)
dirPath = eval('ans');

if ispc()
    dirPath = fullfile(dirPath, 'White Space', filesep);
end
end

