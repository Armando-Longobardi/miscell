function y = find_consecutive_ones(LI)
% FIND START AND END INDICES OF CONSECUTIVES ONES
%   LI should be  a logical index array

if iscolumn(LI)
    LI=LI';
end

if ~islogical(LI)
    LI=logical(LI);
end


s = regexprep(num2str([0, LI, 0]),' ','');
y = [regexp(s,'01')' regexp(s,'10')'-1];
end
