
matlab_script='FEA_from_dat_v3.m';

destination_folder='X:\Colomba\Cyber Dev kit\Results_FEA\MatlabData\script';


fileList=matlab.codetools.requiredFilesAndProducts('FEA_from_dat_v3.m');

for i_file=1:length(fileList)


copyfile(fileList{i_file},destination_folder,'f')

end
        
        
        
        
        
        