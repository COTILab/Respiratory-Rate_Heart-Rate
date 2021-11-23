function [l2, bgDiffSum, nc, maxF, sumD, sumFg, sumBg,diffWall,edgedist]=computeFeatures(wall,peval)
% l2 - L2 norm
% bgDiffSum - continuity of the thresholded (binary) background
% nc - number of clusters in the thresholded (binary) foreground
% maxF - maximum of the psf convoluted image <- this is very correlated with L2 norm
% sumD - difference between the psf convoluted image and hte original <- this does not really work...
% sumFg - sum of the thresholded (binary) foreground 
% sumBg - sum of the thresholded (binary) background
% diffWall - smoothness of hte results -> very correlated wiht sumD
% edgedist - distance of the global maximum from the border

ncomp = size(wall,2); 
npix = size(wall,1); 
wm=normcMax(wall); % normalize to the maximum value
wpix=reshape(wall, peval.nx, peval.ny, ncomp); % normalized to the L1 norm
wpixm=reshape(wm, peval.nx, peval.ny, ncomp); % normalized to the maximum value

% G = fspecial('gaussian',[5 5],1);
psf = psfgen('lambda', 625, 'na', 1.3, 'pixelsize', 80, 'sizevec', [7 7], 'method', 'gauss', 'nphot',1, 'verbose',0);
wpixf = imfilter(wpix,psf,'same'); % convolution with psf

bgThresh = .1;
fgThresh = .5;
% bg=wpixm<bgThresh;
fg=wpixm>fgThresh;

% feature
sumFg=squeeze(sum(sum(fg>0)));

bgvec=wm<bgThresh;

% feature
sumBg =squeeze(sum(bgvec));
d=abs(wpixf-wpix);

% feature - difference between the psf convoluted image and hte original <- this does not really work...
sumD=squeeze(sum(sum(d,1),2))/npix;

% feature - maximum of the psf convoluted image <- this is very correlated with L2 norm
% maxF=squeeze(max(max(normalize(wpixf,1))));
maxF=squeeze(max(max(wpixf)));

% feature - continuity of the thresholded (binary) background
bgDiffSum=sum(abs(diff(bgvec)),1)'/npix;

% feature - L2 norm
l2=sum(wall.^2,1)'/npix;

% feature
[L,n] = bwlabelStack(fg, 4);
% t=convertLabelsToTable(L,n);
% tnorm=bsxfun(@rdivide,t,max(t,[],2));
% nc=(sum(tnorm>.7,2)); % number of clusters of similar size
% % figure('name','number of clusters'); imstiled(reshape(wall,peval.nx, peval.ny, ncomp),[],[],nc)
nc = n';

% feature - smoothness of hte results
diffWall = sum(abs(diff(wall,1,1)))'/npix;

% feature - distance of the global maximum from the border:
maxcol=max(wall,[],1);
wones=bsxfun(@times,ones(size(wall)),maxcol);
maxpix=(reshape(wones,peval.nx,peval.ny,size(wall,2))==wpix);
for ii=1:size(wall,2)
    [maxx,maxy]=find(maxpix(:,:,ii));
    edgedist(ii)=min([maxx-1,peval.nx-maxx, maxy-1, peval.ny-maxy]); 
end
edgedist = edgedist';
    