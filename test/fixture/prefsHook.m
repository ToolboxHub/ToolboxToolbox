%% A hook that throws an error based on the current working prefs.

prefs = tbCurrentPrefs();
error(prefs.projectRoot);
