[out, th_value] = threshold(rcc,'isodata',1);
siz = size(out);
% out=fliplr(out);
a=zeros(siz(1:2));
num=1;
for ind=1:siz(1)*siz(2)
    [i,j] = ind2sub(siz(1:2),ind);
    if a(ind) == 0
        indexlabel = intersect(find(out(:,:,ind-1)>0),find(a==0));
        if ~isempty(indexlabel)
            a([indexlabel; ind]) = num;
            
            num=num+1;
        end
    end
end