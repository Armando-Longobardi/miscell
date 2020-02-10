clear
clc


%% Path selection
% Folder selection
RawPath = uigetdir('C:\Users\villael001\Desktop\Test','Folder of raw');
DewePath = uigetdir(RawPath,'Folder of .mat excracted from dewe');

cdir_raw=dir([RawPath,filesep,'*.raw']);
rawData=sort({cdir_raw.name});
cdir_mat=dir([DewePath,filesep,'*.mat']);
matData=sort({cdir_mat.name});
if isempty(matData)
   error('No exctracted files (*.mat) present in the selected folder') 
end

if isempty(rawData)
   error('No no raw file present in the selected folder') 
end

if length(matData) ~= length(rawData)
    error('number of raw files not correspondent to the number of mat files')
else
    for i=1:length(matData)
        matrix(i,:)={rawData{i} matData{i} 'Cen'}; %#ok<SAGROW>
    end
    
    
    First_row={'CT_Files' 'DeweFiles' 'SN Position'};
    cd(RawPath)
    xlswrite('Association.xlsx',[First_row;matrix],'Sheet1')
end
 