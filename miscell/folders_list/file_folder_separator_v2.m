function [ files ,folders ] = file_folder_separator_v2( folder_name )
%With this function, given a directory, you have two cell arrays in which
%the names of folders and files are separated
%   Detailed explanation goes here
if nargin == 0
    pippo= cd;
    folder_name = char(pippo);
end

WF=dir;
folders=[];

% files=cell([WF_size 1]);
% folders=cell([WF_size 1]);

for i=1:size(WF,1)
    
    % searching_folder=strfind(WF(i).name, '.' );
    
    % if isempty(searching_folder)
    %     folders(j,:) = cellstr(WF(i).name);
    %     j=j+1;
    % else
    %     files(k,:) = cellstr(WF(i).name);
    %     k=k+1;
    % end
    folders={WF([false,false,WF(3:end).isdir]).name}';
    files={WF(~[false,false,WF(3:end).isdir]).name}';
end


end

