function file_unfolding(dir_in)

if nargin<1
    dir_in=uigetdir();
end
% list all subfolders
dir_out=dir(dir_in);
dir_out(strcmp({dir_out.name},'.'))=[];
dir_out(strcmp({dir_out.name},'..'))=[];
 
dir_out(not([dir_out.isdir])) = [];

% move all from subfolders to dir_in
for iFold=1:length(dir_out)
    
        movefile(strjoin({dir_in,dir_out(iFold).name,'*'},filesep),...
            dir_in);
        
        rmdir(strjoin({dir_in,dir_out(iFold).name},filesep))
end