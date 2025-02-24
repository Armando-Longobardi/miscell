function y = find_repeated_values(x)
% FIND START AND END INDICES OF CONSECUTIVES REPEATED VALUES
%   Detailed explanation goes here
s = regexprep(num2str([1 diff(x)~=0 1]),' ','');
y = [regexp(s,'10')' regexp(s,'01')'];
end
