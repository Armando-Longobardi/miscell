function [filenameC,flag] = correctLongPath(filename)
% Add magic prefix to long filepaths.
%   https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation
%% Input check
flag = false;

    if isstring(filename)
        filename = char(filename);
    end
    if ~ischar(filename)
        filenameC = '';
        warning('Input was not valid. Use a char array')
        return
    end
%% Do the magic
if numel(filename)>260
    if strcmp(filename(2:3),':\') 
        % drive notation
        filenameC = ['\\?\',filename];
        flag = true;
    elseif strcmp(filename(1:2),'\\') 
        % UNC path
        filenameC = strrep(filename,'\\','\\?\UNC\');
        flag = true;
    else
        % nothing known
        filenameC = '';
        warning('Path format not recognized, sorry')
    end
else
    % nothing to do
    filenameC = filename;
    flag = true;
end