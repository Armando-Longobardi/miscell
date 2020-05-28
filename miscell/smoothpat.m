function y = smoothpat(x, s_mode, N, varargin)
% clona smoothdata

if ~isempty(varargin)
    n_passes = varargin{1};
else
    n_passes = 1;
end

if n_passes > 1
    x = smoothpat(x, s_mode, N, n_passes - 1);
end

if length(x) == size(x, 1)
    x = x';
    reshape_end = true;
else
    reshape_end = false;
end


y = zeros(size(x));

if strcmp(s_mode, 'movmean')
    for ii = 1:length(x)
        i0 = max([1 (ii - ceil(N/2))]);
        i1 = min([length(x) (ii + floor(N/2))]);
        y(ii) = mean(x(i0:i1));
    end
elseif strcmp(s_mode, 'gaussian')
    wv = zeros(1, 2*floor(N/2) + 1);
    xv = linspace(-2.5, 2.5, length(wv));
    for ii = 1:length(wv)
        wv(ii) = normpdf(xv(ii), 0, 1);
    end
    for ii = 1:length(x)
        i0 = max([1 (ii - floor(N/2))]);
        i1 = min([length(x) (ii + floor(N/2))]);
        if i0 == 1
            wvt = wv(end - i1 + 1:end);
        elseif i1 == length(x)
            wvt = wv(1:(i1 - i0 + 1));
        else
            wvt = wv;
        end
        y(ii) = sum(wvt.*x(i0:i1)) / sum(wvt);
    end
%     keyboard
elseif strcmp(s_mode, 'triangular')
    wv = zeros(1, 2*floor(N/2) + 1);
    xv = linspace(-2.5, 2.5, length(wv));
    %for ii = 1:length(wv)
    %    wv(ii) = normpdf(xv(ii), 0, 1);
    %end
    wv = gen_triang(xv);
    for ii = 1:length(x)
        i0 = max([1 (ii - floor(N/2))]);
        i1 = min([length(x) (ii + floor(N/2))]);
        if i0 == 1
            wvt = wv(end - i1 + 1:end);
        elseif i1 == length(x)
            wvt = wv(1:(i1 - i0 + 1));
        else
            wvt = wv;
        end
        y(ii) = sum(wvt.*x(i0:i1)) / sum(wvt);
    end
else
    warning('Unsupported smooth mode');
end

if reshape_end
    y = y';
end

    function yt = gen_triang(xt)
        N_t = length(xt);
        Nt1 = floor(N_t/2);
        Nt2 = N_t - Nt1;
        yt = [linspace(0, 1, Nt1) linspace(1, 0, Nt2)];
    end


end