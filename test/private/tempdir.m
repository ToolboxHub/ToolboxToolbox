function dirPath = tempdir()
% Overriden matlab tempdir only for tbtb tests. 
% It geneartes a temp directory path with white space in it.
%
% This breaks something under mac/linux.  I think it was added
% to test some Windows specific code.  Making it conditional
% on ispc.

functions = which('tempdir', '-all');
builtinTempDir = functions{end};
run(builtinTempDir)
if (ispc)
	dirPath = fullfile(eval('ans'), 'White Space', filesep);
else
	dirPath = eval('ans');
end
end

