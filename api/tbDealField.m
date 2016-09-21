function s = tbDealField(s, fieldName, value)
% Similar to built-in deal, but with error checking.
%
% s = tbDealField(s, fieldName, value) deals the given value to the given
% fieldName of struct array s.  This is similar to the built-in deal()
% function, but does error checking for Matlab version compatibility.
%
% 2016 benjamin.heasly@gmail.com

if isempty(s)
    return;
end

[s.(fieldName)] = deal(value);
