function values = tbCollectField(s, fieldName, varargin)
% Collect values across a field of a struct array.
%
% values = tbCollectField(s, fieldName) collects values across the given
% fieldName of the struct array s.  This is similar to [s.fieldName] or
% {s.fieldName}, but does error checking for Matlab version compatibility.
%
% tbCollectField( ... 'template', template) specify a template for the
% array type to hold the collected values.  The default is {}, use a cell
% array.  Another possibility is [].
%
% 2016 benjamin.heasly@gmail.com

parser = inputParser();
parser.addRequired('s', @(s) isempty(s) || isstruct(s));
parser.addRequired('fieldName', @ischar);
parser.addParameter('template', {});
parser.parse(s, fieldName, varargin{:});
s = parser.Results.s;
fieldName = parser.Results.fieldName;
template = parser.Results.template;

if isempty(s) || ~isfield(s, fieldName)
    values = template;
    return;
end

if iscell(template)
    values = {s.(fieldName)};
else
    values = [s.(fieldName)];
end
