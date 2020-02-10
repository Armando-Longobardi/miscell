clear
clc
%%
starting_dir='\\group.pirelli.com\PIRELLI_SHARES\IT_MILAN5_TY5004_CYBERTYRE\TestData\SampleB\OutdoorTest\Alfa_Romeo_Giulia_Q_ FN706LS\20190131_Vizzola_ImpronteDinamiche\test';

CANsource_sub='\test\';
saving_sub='\test_AL\';

waiting_window = waitbar(0/12,strcat('Progress:',32,'0',32,'/',32,num2str(12),32,'files completed'));

for i_cond=1:6
    
    fold_cond=['\C',num2str(i_cond)];
    
    files1=dir([starting_dir,fold_cond,saving_sub,'\*.test.mat']);
    files_names={files1.name};
    
    counter=0;
    for file_name=files_names

        counter=counter+1;
        waiting_window = waitbar(((i_cond-1)*2+counter)/12,waiting_window,strcat('Progress:',32,num2str(((i_cond-1)*2+counter)),32,'/',32,num2str(12),32,'files completed'));

        
        load([starting_dir,fold_cond,saving_sub,file_name{:}])
        clear DecodedCAN
        
        load([starting_dir,fold_cond,CANsource_sub,file_name{:}],'DecodedCAN')
        
        save([starting_dir,fold_cond,saving_sub,file_name{:}],'Configuration','DecodedCAN','name','Tire','TyreInfo','StartTimestamp')
        clear('Configuration','DecodedCAN','StartTimestamp','TyreInfo','Tire','name')
    end
end

close(waiting_window)