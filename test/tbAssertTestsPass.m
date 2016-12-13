function results = tbAssertTestsPass(varargin)
% Find and run tests in a folder, error if they don't all pass.
%
% results = tbAssertTestsPass() looks for Matlab Unit Tests in the current
% folder and subfolders, and runs them.  If there's an error, or if not all
% tests pass, throws an exception.  Otherwise, happily returns an array of
% test results.
%
% tbAssertTestsPass( ... 'testFolder', testFolder) specifies where to look
% for Matlab Unit Tests.  The default is pwd().
%
% tbAssertTestsPass( ... 'resultsFile', resultsFile) specifies where to
% write a file containing detailed test results (using the TAP protocol).
% The default is 'testResults.tap'.
%
% 2016 benjamin.heasly@gmail.com

import matlab.unittest.TestRunner;
import matlab.unittest.TestSuite;
import matlab.unittest.plugins.TAPPlugin;
import matlab.unittest.plugins.ToFile;
import matlab.unittest.Verbosity;

parser = inputParser();
parser.addParameter('testFolder', pwd(), @ischar);
parser.addParameter('resultsFile', 'testResults.tap', @ischar);
parser.parse(varargin{:});
testFolder = parser.Results.testFolder;
resultsFile = parser.Results.resultsFile;

% gather tests in the given folder
suite = TestSuite.fromFolder(testFolder, 'IncludingSubfolders', true);
runner = TestRunner.withTextOutput('Verbosity', Verbosity.Verbose);
if ismethod('TAPPlugin', 'producingVersion13')
    % new TAP plugin format and additional diagnostics
    runner.addPlugin(TAPPlugin.producingVersion13(ToFile(resultsFile)), ...
        'IncludingPassingDiagnostics', true);
else
    % old, more compatible TAP plugin
    runner.addPlugin(TAPPlugin.producingOriginalFormat(ToFile(resultsFile)));
end


%% Report test failures as an exception.
results = runner.run(suite);
failureCount = sum([results.Failed]);
if failureCount > 0
    error('tbAssertTestsPass:someTestsFailed', ...
        '%d of %d tests failed from folder "%s".', ...
        failureCount, ...
        numel(results), ...
        testFolder);
end
