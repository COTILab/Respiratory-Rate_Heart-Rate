function [dist, indexmutual]=locerr2(xt,yt,xl,yl,showimage)
% [dist, indexmutual]=locerr(xt,yt,xl,yl)
% Estimates minimum distances between the localized points (xl,yl) and the
% true locations (xt,yt) in the vector dist
% this version tries all n! combination (usable only for n<10)
sl=size(xl);
if sl(1)<sl(2) %making column vectors
    xl=xl'; yl=yl';
end
st=size(xt);
if st(1)<st(2) %making column vectors
    xt=xt'; yt=yt';
end
st=length(xt);
mt=[xt,yt];
ml=[xl,yl];

m=[mt;ml];
mdist=squareform(pdist(m)); %distance matrix
mdistmutual=mdist(st+1:end, 1:st); %mutual distances
[dist, indexmutual]=findminimaldist(mdistmutual);
if ~exist('showimage','var')
    showimage=1;
end
if showimage
    scatterpoints(xt,yt,xl,yl,indexmutual)
end
end

function [md, rowsort] = findminimaldist(A)
%find minimum mutual distances and makes sure that each point is allocated
%only one localized position
sv = size(A);
ilin=1:min(sv);
pm=perms(1:min(sv));
dold=intmax;
for ii=1:size(pm,1) %all n! configurarions
    index=sub2ind(size(A),pm(ii,:),ilin);
    d=sum(A(index));
    if d<dold
        dold=d;
        indmin=pm(ii,:);
        md=A(index);
    end
end

rowsort=indmin;
end

function scatterpoints(xt,yt,xl,yl,indexmutual)
lindex = length(indexmutual);

co=get(gca, 'colororder');
lco=length(co);
rat = lindex/lco;

if rat > 1 %more clusters than colors
    co = repmat(co, ceil(rat), 1);
end
figure; hold on
for ii=1:lindex
    scatter(xt(ii), yt(ii),[],co(ii,:));
    scatter(xl(indexmutual(ii)),yl(indexmutual(ii)),[],co(ii,:),'x');
    line([xt(ii), xl(indexmutual(ii))], [yt(ii),yl(indexmutual(ii))],'color',co(ii,:));
     grid on
    l{1}='true'; l{2}='estimate';
    legend(l)
end
end
