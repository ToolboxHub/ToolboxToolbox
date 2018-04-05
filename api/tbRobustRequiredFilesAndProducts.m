function [fList, pList] = tbRobustRequiredFilesAndProducts(filename)
% More robust version of matlab.codetools.requiredFilesAndProducts
%
% Syntax:
%   [fList, pList] = tbRobustRequiredFilesAndProducts(filename)
%
% Description:
%    Wrapper around matlab.codetools.requiredFilesAndProducts, that
%    attempts to handle some exceptions.

try
    [fList,pList] = matlab.codetools.requiredFilesAndProducts(filename(:));
catch e
    switch e.identifier
        case 'MATLAB:depfun:req:InternalNoClassForMethod' 
            % Some class not on path; add and retry
            file = regexp(e.message,'\".*\.m','match');
            file = file{1}(2:end);
            filepath = fileparts(file);
            addpath(filepath);
        case 'MATLAB:depfun:req:BadSyntax' 
            % Some code error in a file
            file = regexp(e.message,"\'.*\.m",'match');
            file = file{1}(2:end);
            err = regexp(e.message,":.*",'match');
            err = err{1}(3:end);
            exception = MException('ToolboxToolbox:FindFileDependencies:CodeError',...
            'Dependencies for %s cannot be found, because it contains code errors:\n%s', file, err);
            exception.addCause(e);
            throw(exception);
        otherwise
            % Don't know, rethrow
            rethrow(e);
    end
    % Handled some exception without (re)throwing -- reattempt.
    [fList,pList] = tbRobustRequiredFilesAndProducts(filename);
end

end

