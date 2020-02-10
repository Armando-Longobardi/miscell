clear
clc
% close all

% parent_folder=uigetdir('C:\Users\longoar001\Desktop\AL_desk\Data test\');
% cd(parent_folder)

% folders1=dir();
% folders={folders1([folders1.isdir]).name};
% log_ind=cellfun(@(x) strcmp(x,'.'),folders,'UniformOutput',0};
% folders=folders(log_ind);

% folders{1}='Z:\TestData\SampleB\IndoorTest\MTS\225-50ZR17 - P7 Cinturato\P81006\raw';
% folders{1}='Z:\TestData\SampleB\IndoorTest\MTS\225-50ZR17 - P7 Cinturato\P81007\raw';
% folders{1}='Z:\TestData\SampleB\IndoorTest\MTS\225-50ZR17 - P7 Cinturato\P81008\raw';
folders{1}='Z:\TestData\SampleB\IndoorTest\MTS\225-50ZR17 - P7 Cinturato\P81009\raw';

RR=[];

for i= 1:size(folders,2)
%     cd(folders{i})
    file_data1=dir([folders{i},filesep,'*.data']);
    file_data=strcat(folders{i},filesep,{file_data1.name});
    for j=1:size(file_data,2)
        FT=GetFlatTracData(file_data{j});
        for k=1:size(FT,2)
            RR=[RR;abs(FT(k).Data.Vr_Filtered/3.6)./abs(FT(k).Data.Vs_Filtered/60*2*pi)];
        end
    end
%     cd ..
end
% cd ..

RR_mean=mean(RR);
RR_median=median(RR);

figure('NumberTitle','off','Name','RR')
plot(RR,'DisplayName','Rolling Radius')
hold on
plot([1 length(RR)],[RR_mean RR_mean],'DisplayName',['Mean =',32,num2str(RR_mean)])
plot([1 length(RR)],[RR_median RR_median],'DisplayName',['Median =',32,num2str(RR_median)])
grid on
xlabel('nSamples')
ylabel('Rolling Radius [m]')
grid on
legend show
% savefig('RR')


RR_noref=[];

for i= 1:size(folders,2)

    file_data1=dir([folders{i},filesep,'Step*.data']);
    file_data=strcat(folders{i},filesep,{file_data1.name});
    for j=1:size(file_data,2)
        FT=GetFlatTracData(file_data{j});
        for k=1:size(FT,2)
            RR_noref=[RR_noref;abs(FT(k).Data.Vr_Filtered/3.6)./abs(FT(k).Data.Vs_Filtered/60*2*pi)];
        end
    end
end





RR_mean_noref=mean(RR_noref);
RR_median_noref=median(RR);

figure('NumberTitle','off','Name','RR no ref')
plot(RR_noref,'DisplayName','Rolling Radius')
hold on
plot([1 length(RR_noref)],[RR_mean_noref RR_mean_noref],'DisplayName',['Mean =',32,num2str(RR_mean_noref)])
plot([1 length(RR_noref)],[RR_median_noref RR_median_noref],'DisplayName',['Median =',32,num2str(RR_median_noref)])
grid on
xlabel('nSamples')
ylabel('Rolling Radius [m]')
grid on
legend show
% savefig('RR no ref')
