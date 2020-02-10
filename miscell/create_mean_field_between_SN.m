clear
clc

load('\\group.pirelli.com\PIRELLI_SHARES\IT_MILAN5_TY5004_CYBERTYRE\TestData\SampleB\IndoorTest\Banco_Ottico\20190123 - Alfa Romeo Giulia QV - front & rear\Giulia_indoor_2019_v1.mat')

axle={'front','rear'};
tire_name={'245/35R19','285/30R19'};
pressures.front={'P210','P270','P330'};
pressures.rear={'P190','P250','P310'};


SNs={'SN0','SN1','SN2','SN3'};

for i_axle=1:2
    for i_p=1:length(pressures.(axle{i_axle}))
        for field=fieldnames(handy_lengths_scr_ind.(axle{i_axle}).([pressures.(axle{i_axle}){i_p},'_',SNs{1}]))'
            handy_lengths_scr_ind.(axle{i_axle}).(pressures.(axle{i_axle}){i_p}).(field{:}) = mean([ ...
                handy_lengths_scr_ind.(axle{i_axle}).([pressures.(axle{i_axle}){i_p},'_',SNs{1}]).(field{:}); ...
                handy_lengths_scr_ind.(axle{i_axle}).([pressures.(axle{i_axle}){i_p},'_',SNs{2}]).(field{:}); ...
                handy_lengths_scr_ind.(axle{i_axle}).([pressures.(axle{i_axle}){i_p},'_',SNs{3}]).(field{:}); ...
                handy_lengths_scr_ind.(axle{i_axle}).([pressures.(axle{i_axle}){i_p},'_',SNs{4}]).(field{:})]);
        
        end
    end
    handy_lengths_scr_ind.(axle{i_axle})=orderfields(handy_lengths_scr_ind.(axle{i_axle}));
end
        
save('\\group.pirelli.com\PIRELLI_SHARES\IT_MILAN5_TY5004_CYBERTYRE\TestData\SampleB\IndoorTest\Banco_Ottico\20190123 - Alfa Romeo Giulia QV - front & rear\Giulia_indoor_2019_v2.mat','DATA9_scr_ind','handy_lengths_scr_ind')
        
        
