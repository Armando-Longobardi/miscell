clear
clc

dir_home='C:\Users\longoar001\Desktop\AL_desk\Data test\Outdoor\Audi_A4\WK13Loop_copia locale\20190403_IDIADA_Day2';


     
temp1=dir([dir_home,'\raw\*.raw']);
filenames.raw= {temp1.name}';


temp2= dir([dir_home,'\Dewe\*.dxd']);
filenames.dewe={temp2.name}';

clear('temp1','temp2')
