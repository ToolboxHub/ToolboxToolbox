function dirPath = tempdir()
% overriden matlab temdir to genearted directory name with white space

functions = which('tempdir', '-all');
builtinTempDir = functions{end};
run(builtinTempDir)
dirPath = fullfile(eval('ans'), 'White Space', filesep);
end

