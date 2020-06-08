function m_out = combvec(v1, v2, varargin)
% Patrucco, 2018
% v 1.0 (09/01/2019):
%   Replica of MathWorks' combvec (requiring Neural Networks TB). Requires
%   v1 and v2 (and any other in varargin) to be row or row-like.

if isempty(varargin)
    nrows = size(v1, 1) + size(v2, 1);
    ncols = size(v1, 2)*size(v2, 2);
    N1 = size(v1, 2);
    N2 = size(v2, 2);
    m_out = zeros(nrows, ncols);
    for i1 = 1:N1
        for i2 = 1:N2
            ii = ((i1 - 1)*N2) + i2;
            m_out(1:size(v1, 1), ii) = v1(:, i1);
            m_out(size(v1, 1)+1:size(v1, 1)+size(v2, 1), ii) = v2(:, i2);
        end
    end
else
    if length(varargin) > 1
        m_out = combvec(v1, combvec(v2, varargin{1}, varargin{2:end}));
    else
        m_out = combvec(v1, combvec(v2, varargin{1}));
    end
end
