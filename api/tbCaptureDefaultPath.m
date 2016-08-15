function defaultPath = tbCaptureDefaultPath()
% Ask Matlab for its default path, without messing up the current path.
%
% defaultPath = tbCaptureDefaultPath() lets Matlab restore its own default
% path and gets the value of that path.  Then it restores the original path
% to what it was before.
%
% It would be nice if we could just ask Matlab for the default path without
% restoring it.  But Matlab doesn't play that, so we would have to hack
% into the guts of restoredefaultpath.m, which seems like asking for
% brittle behavior.  So instead, make a best effort to restore the original
% path with try/catch.
%
% 2016 benjamin.heasly@gmail.com

originalPath = path();
try
    wid = 'MATLAB:dispatcher:pathWarning';
    oldWarningState = warning('query', wid);
    warning('off', wid);
    restoredefaultpath();
    warning(oldWarningState.state, wid);
    
    defaultPath = path();
catch err
    path(originalPath());
    rethrow(err);
end

path(originalPath());
