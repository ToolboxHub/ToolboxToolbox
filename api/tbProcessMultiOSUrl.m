function url = tbProcessMultiOSUrl(multiOSUrl)
% Convert a multi-computer url to a url for the current computer
%
% url = tbProcessMultiComputerURL(multiOSUrl)
%
% The toolbox toolbox will accept a string array in the form
% ['OSType1' 'url1' 'OSType2 'url2' ...] where 'OSTypeN'
% is a string returned by the Matlab computer command.
%
% This allows us to fetch, for example, different precompiled sdk's
% to match the current os type.
%
% Takes advantage of string arrays, and only works with R2016b and later.
%
% Here is an example of the URL record where we use this feature:
%  "url": [
%          "MACI64"
%          "https://stanford.box.com/shared/static/j89elq3upt0ojxaju4cxwyft6heuiwnk.zip"
%          "GLNXA64" 
%          "https://stanford.box.com/shared/static/wnrmyhud3og6zcnevmpf2147e5trza7x.zip"
%         ]

% Check for os dependent record.  We can only do this if isstring exists,
% which is true in R2016b and later.  Otherwise, we cannot handle
% multi-computer URL records.
if (exist('isstring','builtin'))
    if (isstring(multiOSUrl))
        if (rem(length(multiOSUrl),2) ~= 0)
            error('Multi-OS URL record must have an even number of entries');
        end
        gotURL = false;
        for ii = 1:2:length(multiOSUrl)
            if (strcmp(computer,multiOSUrl(ii)))
                url = char(multiOSUrl(ii+1));
                gotURL = true;
                break;
            end
        end
        if (~gotURL)
            error('Did not find a URL for this OS type in multi-OS URL');
        end
    else
        url = multiOSUrl;
    end
else
    if (~ischar(multiOSUrl))
        error('Can only handle multi-OS URLs in R2016b and later');
    end
    url = multiOSUrl;
end

