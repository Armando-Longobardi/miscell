clear 
clc

% addpath('C:\Users\longoar001\Documents\MATLAB\CTRoutines\trunk\EV\SampleC')


path_folder='Z:\TestData\Wear\indoor\1.7 Shaker Ciampolini\SampleC\test';

dir_out=dir([path_folder,filesep,'*.mat']);

files={dir_out.name};


%% carica files
test_fieldname=cell(length(files),1);

for i_file=1:length(files)
    
    temp = regexp(files{i_file}(1:end-9),'_','split');
    
    test_fieldname{i_file}=[temp{1},'_',strrep(temp{end},'-','')];
    
%     CDataSet.(test_fieldname{i_file})= load([path_folder,filesep,files{i_file}]);
    
%     CDataSet.(test_fieldname{i_file}).SampleC= C_SamplingTimeEval(CDataSet.(test_fieldname{i_file}).SampleC);
end

LostTab = table('Size',[length(files) 5],'VariableTypes',repmat({'double'},5,1),...
    'VariableNames',{'Zlost','Xlost','Ylost','Turn_Zlost','Turn_anylost'},...
    'RowNames',test_fieldname);

%% cerca complessi

for i_file=1:length(files)
%     figure('Position',[1 41 1920 963])
    
%     plot(CDataSet.(test_fieldname{i_file}).FT.Data.Time,-CDataSet.(test_fieldname{i_file}).FT.Data.Vsd_Filtered*2*pi/60)

%     hold on
    
 
     CData_temp= load([path_folder,filesep,files{i_file}]);


CDataSet.(test_fieldname{i_file}).complex_ind = false(length(CDataSet.(test_fieldname{i_file}).SampleC.Data.FL_wheel.SN2.turn),1);
    
    CDataSet.(test_fieldname{i_file}).firstcomplex_ind = zeros(length(CDataSet.(test_fieldname{i_file}).SampleC.Data.FL_wheel.SN2.turn),1);
    
    for i_turn = 1:length(CDataSet.(test_fieldname{i_file}).SampleC.Data.FL_wheel.SN2.turn)
        
        CDataSet.(test_fieldname{i_file}).complex_ind(i_turn)=any(angle(CDataSet.(test_fieldname{i_file}).SampleC.Data.FL_wheel.SN2.turn(i_turn).info.Time)~=0);
        
        if CDataSet.(test_fieldname{i_file}).complex_ind(i_turn)
            
            CDataSet.(test_fieldname{i_file}).firstcomplex_ind(i_turn)=find(angle(CDataSet.(test_fieldname{i_file}).SampleC.Data.FL_wheel.SN2.turn(i_turn).info.Time)~=0,1);
            
        end
%         hold on
%         color_pallino = 'gr';
%         
%         
%         
%         plot((CDataSet.(test_fieldname{i_file}).SampleC.Data.FL_wheel.SN2.turn(i_turn).info.timestampVeu-CDataSet.(test_fieldname{i_file}).SampleC.StartTimestamp)/1000,...
%             CDataSet.(test_fieldname{i_file}).SampleC.Data.FL_wheel.SN2.turn(i_turn).info.AngularSpeed,...
%             'Marker','o','Color',color_pallino(complex_ind(i_turn)+1),'MarkerSize',6+3*complex_ind(i_turn))
        
    end
    
    
end
    
%% plotta info
    figure('Position',[1 41 1920 963])

hold on
for i_file=1:length(files)
    
    
    plot(CDataSet.(test_fieldname{i_file}).firstcomplex_ind,'DisplayName',strrep(test_fieldname{i_file},'_',' '))
    
    
end

    grid on
    legend('show')
    
    

    
    for i_file=1:length(files)
    
    
        CDataSet.(test_fieldname{i_file}).complex_ratio = sum(CDataSet.(test_fieldname{i_file}).complex_ind)/length(CDataSet.(test_fieldname{i_file}).complex_ind)*100;
    
        
    end

        for i_file=1:length(files)

            StructXTable.complex_ratio(i_file)=CDataSet.(test_fieldname{i_file}).complex_ratio;
    
        end
    
       peppino=table(StructXTable.complex_ratio','RowNames',test_fieldname);
    
       save('peppino','peppino')
       