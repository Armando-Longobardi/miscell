function file_subfolding(dir_in,n_split,delimiter)

if nargin<1
    dir_in=uigetdir();
end
dir_out=dir(dir_in);
dir_out(strcmp({dir_out.name},'.'))=[];
dir_out(strcmp({dir_out.name},'..'))=[];

if nargin<2
    n_split=inputdlg(dir_out(1).name,'nSplit choiche');
    n_split = str2double(n_split{1});
end


if nargin<3
    delimiter='_';
end



pippo=cellfun(@(x) regexp(x,delimiter,'split'),{dir_out.name},'UniformOutput',0);
if n_split>0
     pippo=cellfun(@(x) x{n_split},pippo,'UniformOutput',0);   
else
 pippo=cellfun(@(x) x{end+n_split},pippo,'UniformOutput',0);   
end

[dir_out.tyre]=pippo{:};
for iFile=1:length(dir_out)
    try
        movefile(strjoin({dir_out(iFile).folder,dir_out(iFile).name},filesep),...
            strjoin({dir_out(iFile).folder,dir_out(iFile).tyre,dir_out(iFile).name},filesep));
    catch
        mkdir(strjoin({dir_out(iFile).folder,dir_out(iFile).tyre},filesep));
        movefile(strjoin({dir_out(iFile).folder,dir_out(iFile).name},filesep),...
            strjoin({dir_out(iFile).folder,dir_out(iFile).tyre,dir_out(iFile).name},filesep));
    end
end