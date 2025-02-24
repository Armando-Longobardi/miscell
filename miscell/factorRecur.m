function [fMax,n]=factorRecur(b)

fMax=1;
n=1;
ii=1;

t=factor(b(1));

while not(isempty(t)) && ii<numel(b)
    n=ii;
ii=ii+1;


fMax=prod(t);

t2=factor(b(ii));

for jj=1:numel(t)
    if ismember(t(jj),t2)
        t2(find(t2==t(jj),1))=[];
    else
        t(jj)=NaN;
    end
end

t(isnan(t))=[];

end

if not(isempty(t))
    n=n+1;
    fMax=prod(t);
end

end