function results = runTestsAndExit(varargin)
% Invoke from the command line to run tests with diagnostics and exit code.

% a sample command for poc
%  matlab -nodisplay -r "runAllTests('setupCommand', 'tbUse(''RenderToolbox4'')', 'tests', '/home/ben/toolboxes/RenderToolbox4/Test/Automated');"

import matlab.unittest.TestRunner;
import matlab.unittest.plugins.TAPPlugin;
import matlab.unittest.plugins.ToFile;
import matlab.unittest.Verbosity;

try
    % input errors should be trapped
    parser = inputParser();
    parser.addParameter('setupCommand', '', @ischar);
    parser.addParameter('tests', pwd(), @ischar);
    parser.addParameter('resultsFile', 'testResults.tap', @ischar);
    parser.parse(varargin{:});
    setupCommand = parser.Results.setupCommand;
    tests = parser.Results.tests;
    resultsFile = parser.Results.resultsFile;
    
    if ~isempty(setupCommand)
        % set up the toolbox environment
        eval(setupCommand);
    end
    
    % gather tests in the given folder (or package, classs, etc.)
    suite = testsuite(tests, ...
        'IncludeSubfolders', true, ...
        'IncludeSubpackages', true);
    runner = TestRunner.withTextOutput('Verbosity', Verbosity.Verbose);
    if ismethod('TAPPlugin', 'producingVersion13')
        % new TAP plugin format and additional diagnostics
        runner.addPlugin(TAPPlugin.producingVersion13(ToFile(resultsFile)), ...
            'IncludingPassingDiagnostics', true);
    else
        % old, more compatible TAP plugin
        runner.addPlugin(TAPPlugin.producingOriginalFormat(ToFile(resultsFile)));
    end
    
    % report results to the caller
    results = runner.run(suite);
    failureCount = sum([results.Failed]);
    exit(failureCount);
    
catch err
    % report error to the caller
    disp(getReport(err, 'extended'));
    exit(-1);
end
