clear
clc
%%
starting_dir='C:\Users\longoar001\Desktop\AL_desk\Data test\Outdoor\Audi_A4\WK13Loop_copia locale';

xls_TestList='Z:\TestData\SampleB\OutdoorTest\Audi_A4\19WK12_AudiA4_ObjHandlingLoop\TestList_PirelliCT_LoopSviluppo_Wk13.xlsx';

fields_always={'File_name','Start_time','Number_of_channels','Sample_rate','Store_type','Pre_time','Post_time','Events','Start_trigger_times'};

test_day='20190403_IDIADA_Day2';


[~,~,pippo]=xlsread(xls_TestList,test_day,'A2:I29');

log_ing_emptyrow=cell2mat(cellfun(@(x) any(~isnan(x)),pippo(:,1),'UniformOutput',0));
log_ind_flag=~cell2mat(cellfun(@(x) all(x==1),pippo(:,9),'UniformOutput',0));
log_ind=and(log_ing_emptyrow,log_ind_flag);

data_from_xls=pippo(log_ind,1:3);
nFiles=size(data_from_xls,1);

waiting_window = waitbar(0/nFiles,strcat('Progress:',32,'0',32,'/',32,num2str(nFiles),32,'files completed'),'Name',test_day);

%         for i_set={'5','5C','6','7','8'}
%         mkdir([starting_dir,'/',test_day,'/acquisition/set',i_set{:}],'test')
%     end




for i_test=1:nFiles
    waiting_window = waitbar((i_test-1)/nFiles,waiting_window,strcat('Progress:',32,num2str(i_test),32,'/',32,num2str(nFiles),32,'files completed'));
    
    dewe=load([starting_dir,'/',test_day,'/Dewe/',data_from_xls{i_test,3}(1:end-3),'mat']);
    
    
    
    Test=load([starting_dir,'/',test_day,'/raw/',data_from_xls{i_test,2}(1:end-3),'test.mat']);
    
    Test.DecodedCAN=dewe;
    
    save([starting_dir,'/',test_day,'/test/',data_from_xls{i_test,2}(1:end-3),'test.mat'], ...
        '-struct','Test')
    
    clear('Test')
    
end
close(waiting_window)


