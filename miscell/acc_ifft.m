function [acc, vel, spo, jerk, dt_reinterp] = acc_ifft(mod,fase,freq,Nreinterp)

%function [acc, vel, spo, jerk, dt_reinterp] = acc_ifft(mod,fase,freq,Nreinterp)

%#ok<*AGROW>
if isnumeric(mod)
    if all(isnan(mod)) || all(isnan(freq))
        spo = nan(1,Nreinterp);
        vel = nan(1,Nreinterp);
        acc = nan(1,Nreinterp);
        jerk =nan(1,Nreinterp);
        dt_reinterp = NaN;
        
        return
    end
    N=256;
    
    DT_samples=1/freq(2);
    
    timerange=linspace(0,(N-1) * DT_samples/(N),Nreinterp);
    
    dt_reinterp=DT_samples/(Nreinterp-1);
    
    spo = zeros(size(timerange));
    vel = zeros(size(timerange));
    acc = zeros(size(timerange));
    jerk = zeros(size(timerange));
    
    
    for IndexArm = 2:length(mod)%(armin + LastNotZero - 1)
        omega = 2 * pi * freq(IndexArm);
        jerk =         jerk - mod(IndexArm) * sin(omega * timerange + fase(IndexArm)) * omega;    % jerk
        acc = acc + mod(IndexArm) * cos(omega * timerange + fase(IndexArm));          % acc
        vel =         vel + mod(IndexArm) * sin(omega * timerange + fase(IndexArm)) / omega;    % vel
        spo =         spo - mod(IndexArm) * cos(omega * timerange + fase(IndexArm)) / omega^2;  % spo
    end
    
    
elseif iscell(mod)
    
    for i=1:length(mod)
        [acc{i}, vel{i}, spo{i}, jerk{i}, dt_reinterp(i)] = acc_ifft(mod{i},fase{i},freq{i},Nreinterp);
    end
    
    
end
end