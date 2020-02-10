clear
clc
%% intro
file=('\\group.pirelli.com\PIRELLI_SHARES\IT_MILAN5_TY5004_CYBERTYRE\TestData\SampleB\OutdoorTest\Alfa_Romeo_Giulia_Q_ FN706LS\20180827-31_Vizzola_Mozzi\CAN_export_channels.xlsm');
[~,sheets]=xlsfinfo(file);

for i=2:3
    %load names
    [~,columns,~]=xlsread(file,sheets{i},'D:F');
    
    columns(:,1)=cellfun(@(x) correct_name(x),columns(:,1),'UniformOutput',0);
    sorted=columns(:,1:2);
    
    
    for j=1:size(columns,1)
        
        match=find(cell2mat(cellfun(@(x) (strcmp(x,correct_name(['Data1_',columns{j,2}],31))),columns(:,3),'UniformOutput',0)))';
        if isempty(match)
        match=find(cell2mat(cellfun(@(x) (strcmp(x,correct_name(['Data1_',columns{j,1},'_',columns{j,2}],31))),columns(:,3),'UniformOutput',0)))';
        end
        sorted(j,3)=columns(match,3);

    end
    
    xlswrite(file,sorted,[sheets{i},'_sorted'])
end
