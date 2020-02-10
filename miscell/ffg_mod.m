function [mod,fase,freq,fft_output]=ffg_mod(data,N,dt)
%One-sided fast fourier transform
% Works either for matrix or cells
%Sintax: [mod,fase,freq,grf]=ffg(gr,N,dt)


%% check on input
if nargin<2
    N=[];
    dt=NaN;
elseif nargin<3
    dt=NaN;
end



if isnumeric(data)
    %% main
if isempty(N)
    N=length(data);
end
    fft_output=fft(data,N);
    mod(2:round(N/2))=2/N*abs(fft_output(2:round(N/2)));
    mod(1)=abs(mean(data));
    freq=(1/dt)/N*(0:round(N/2-1));
    fase(1)=atan2(0,mean(data));
    fase(2:round(N/2))=atan2(imag(fft_output(2:round(N/2))),real(fft_output(2:round(N/2))));
    
    
    
elseif iscell(data)
    
    for i=1:length(data)
        [mod{i}, fase{i}, freq{i}, fft_output{i}] = ffg_mod(data{i},N,dt(1)); %#ok<*AGROW>
    end
    
else
    error('Data format invalid')
    
end

end