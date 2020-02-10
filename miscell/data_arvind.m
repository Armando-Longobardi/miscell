
% figure
% s1=subplot(2,1,1);
% plot(Tire.Node(1).regs_Int.Time_lin,Tire.Node(1).regs_Int.DR_filtMain_lin)
% s2=subplot(2,1,2);
% plot(FT.Data.Time,FT.Data.FZtd_Filtered)
% linkaxes([s1,s2],'x')
% 
% figure
clear
clc

files=dir;


All_data=[];
for i=4:size(files,1)
    
    load(files(i).name);
    
    
    Tire=MultiCentralNodeGenerator(Tire,[]);
    if isfield(Tire,'regsMN')
        
        time_interp=Tire.regsMN.Time;
         DR=Tire.regsMN.DR_filtMain;
    elseif isfield(Tire.Node,'regs')
        time_interp=Tire.Node(1).regs.Time;
        DR=Tire.Node(1).regs.DR_filtMain;
    else
        continue
    end
        
        
        
        
        
        Fz_interp=interp1(FT.Data.Time,FT.Data.FZtd_Filtered,time_interp);
        V_interp=interp1(FT.Data.Vr_Filtered,time_interp);
        p_interp=interp1(FT.Data.Pt_Filtered,time_interp);
        





% s1=subplot(2,1,1);
% plot(Tire.Node(1).regs_Int.Time_lin,Tire.Node(1).regs_Int.DR_filtMain_lin)
% s2=subplot(2,1,2);
% plot(Tire.Node(1).regs_Int.Time_lin,Fz_interp)
% linkaxes([s1,s2],'x')




All_data=[         All_data                       ;
          Fz_interp',V_interp', p_interp',   DR'   ];
      
end






    logical_ind_all=not(isnan(All_data));
    logical_ind=logical_ind_all(:,1);
    for j=2:4
    logical_ind=and(logical_ind,logical_ind_all(:,j));
    end
    
    Data_good=All_data(logical_ind,:);
    legend={'Load [N]', 'V [km/h]', 'p [kPa]', 'DR [m]'};
    
    save('Data_training','legend','Data_good')