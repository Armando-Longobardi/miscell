function [ files ,folders ] = file_folder_separator_v2( folder_name )
%With this function, given a directory, you have two cell arrays in which
%the names of folders and files are separated
%   Detailed explanation goes here
if nargin == 0
    pippo= cd;
    folder_name = char(pippo);
end

WF=dir;
j=1;
k=1;

WF_size=size(WF,1);

% files=cell([WF_size 1]);
% folders=cell([WF_size 1]);

for i=1:size(WF,1)
    
    searching_folder=strfind(WF(i).name, '.' );
    
    if isempty(searching_folder)
        folders(j,:) = cellstr(WF(i).name);
        j=j+1;
    else
        files(k,:) = cellstr(WF(i).name);
        k=k+1;
    end
end

if ~exist('folders')
    folders=[];
end

end

