URL='https://it.mathworks.com/matlabcentral/cody/players?page=';

Score=[];

for iPage=1:100
    disp(iPage)
    WO=weboptions('Timeout',10);
WR=webread([URL,num2str(iPage)],WO);
temp=cellfun(@str2double,regexp(WR,'Score: (\d+)','tokens'));
Score=[Score,temp(1:2:end)];

end



figure;bar(Score)
figure;bar(diff(Score))