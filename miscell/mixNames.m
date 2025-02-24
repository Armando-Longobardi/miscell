function out = mixNames(Var1,Var2,delimiter)
% Function to create all the combination of two cell arrays of names
[ii,jj] = meshgrid(1:numel(Var1),1:numel(Var2));
out = arrayfun(@(x,y)  [Var1{x},delimiter,Var2{y}],jj,ii,'UniformOutput',false);
end