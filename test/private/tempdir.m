function dirPath = tempdir()
% Overriden matlab temdir only for tbtb tests. 
% It geneartes a temp directory path with white space

functions = which('tempdir', '-all');
builtinTempDir = functions{end};
run(builtinTempDir)
dirPath = fullfile(eval('ans'), 'White Space', filesep);
end

