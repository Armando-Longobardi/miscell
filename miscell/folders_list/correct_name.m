function [ dopo ] = correct_name( prima,max_char )
%Riduco le stringhe a max_char caratteri (30 di default) e sostituisco tutti 
% i caratteri speciali con un underscore

if nargin<2
    max_char=30;
end

if ~ischar(prima)
    error('L input deve essere un array')
end


if size(prima,2)>max_char
    prima=prima(1:max_char);
end

dopo=prima;

for qui=1:length(prima)
    if ismember(prima(qui),' -,;:/!"£$%&/()=?^|*+[]#.')
        dopo(qui)='_';
    end
end


end

