function [x_mu, y_mu sig] = localizew(w,peval,localMaxRadius)
% [x_mu, y_mu sig] = localizew(w,peval,localMaxRadius)
% Localilzes w (#pixels x #components) from NMF model (V=WH)
% peval : parameters (needed peval.nx, peval.ny)
% localMaxDiameter : diameter in pixels to which confine a local maximum search. If set to 0 (default) no confinemend is done.  
if ~exist('localMaxRadius', 'var')
    localMaxRadius = 0; % Finding global max. 
end
K=size(w,2);
wr=reshape(w,peval.nx, peval.ny,K); %K can be different from peval.ncomp if background is takes as one component...
[x,y] = meshgrid(1:peval.ny, 1:peval.nx); % nx and ny has to be swapped as in the image the first coordiante is number of rows
if localMaxRadius
    fprintf('Looking for local maximum %g only.\n', localMaxRadius);
end

x_mu=inf(1,K);
y_mu=inf(1,K);
sig=inf(1,K);
differ=inf(1,K);
for ii=1:K %background is not localized...
    [x_mu(ii), y_mu(ii), sig(ii), differ(ii)] = fitgauss2d(wr(:,:,ii));
    if localMaxRadius>0        
        confinementMaskTmp=(x-x_mu(ii)).^2+(y-y_mu(ii)).^2<=localMaxRadius^2;
        [ymtmp,xmtmp]=find(wr(:,:,ii)==max(max(wr(:,:,ii).*confinementMaskTmp)),1);
        if isempty(xmtmp)&&isempty(ymtmp)
            xmtmp=10*peval.nx;
            ymtmp=xmtmp;
            fprintf('Problem with maximum localisation.\n');
        end
        confinementMask=(x-xmtmp).^2+(y-ymtmp).^2<=localMaxRadius^2; % mask centered on the local maximum
        [x_mu(ii), y_mu(ii), sig(ii), differ(ii)] = fitgauss2d(wr(:,:,ii).*confinementMask);
    end
        
end

if sum(isinf([x_mu, y_mu,sig,differ]))
    warning('Problem with localisation...')
end