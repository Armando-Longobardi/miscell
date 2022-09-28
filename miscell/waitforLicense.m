system('cd "C:\Program Files\MATLAB\R2019b\etc\win64"')
pippo=true;
while pippo
    disp(datetime('now'))
    [a,b]=system('C:\Users\longoar001\Desktop\LicenseSpy_Matlab.bat');
    
    str='Users of Compiler:  (Total of 1 license issued;  Total of ';
    
    pippo=b(regexp(b,str)+numel(str))=='1';
    disp(['Users:',b(regexp(b,str)+numel(str))])
    pause(10)
end
load handel
sound(y,Fs)
beep