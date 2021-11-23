function [imphot, ncoef, bg_im nphot_max, offsetphot, sig,musigix, pm, Mused] = getimparInAct(im,numClick,verbose);
%[imphot, ncoef, bg_im nphot_max, offsetphot, sig,musigix, pm, Mused] =
% getimparInAct(im,numClick,verbose);
% estimates Noise and intensity parameters in the image
% assuming poisson noise only, convert image so that intensity correspond to
% number of photons (var = mean for background...)
%   im: image
%   numClick = umber of blobs for PSF estimation
%   ncoef: coefficient the image must be multiplied to get photon numbers
%   verbose: more detailed infromation
if ~exist('verbose','var')
    verbose =0;  %default is automatic
end

clip = 'no';
fs_var = 2; %5;
bg_perc = 20;
bg_ob_dist = 3;% 15;

[out_nobg, mean_bg, bg_im]=backgroundoffset(im, clip, fs_var, bg_perc, bg_ob_dist);

if verbose
    [mean_bg, var_bg, bg_im] = chooseregion(im, bg_im);
else
    var_bg=var(im,bg_im);
end

fprintf('Estimated backgound %g\n', mean_bg)
fprintf('Estimated variance backgound %g\n', var_bg)


ncoef=mean_bg/var_bg; %Poisson noise: mean=var
imphot=im*ncoef;
offsetphot=mean_bg*ncoef;

nphot_max = [];
sig = [];
musigix = [];
pm = [];
Mused = [];

if verbose == 2
    close all;
    dipshow(1,imphot);
    fprintf('Click on centers %g times \n',numClick)
    coords = dipgetcoords(1,numClick);
    
    
    for ii=1:numClick
        % [maxi, pm]=max(imphot);
        r=2; %size of ROI
        pm_tmp=coords(ii,:);
        if length(pm_tmp)==2
            M=double(imphot(pm_tmp(1)-r:pm_tmp(1)+r,pm_tmp(2)-r:pm_tmp(2)+r));
        elseif length(pm_tmp)==3
            M=double(squeeze(imphot(pm_tmp(1)-r:pm_tmp(1)+r,pm_tmp(2)-r:pm_tmp(2)+r, pm_tmp(3))));
        end
        Mstack(:,:,ii)=M;
        mM(ii)=max(M(:));
        [x_mu(ii), y_mu(ii), sig(ii)] = fitgauss2d(M-offsetphot);
    end
    
    musig=mean(sig);
    varsig=var(sig);
    sigix=find(abs(sig-musig)<sqrt(varsig)); %remove outliers
    musigix=mean(sig(sigix));
    [maxi, pmix]=max(mM(sigix));
    maxix=sigix(pmix);
    pm=coords(maxix,1:2)-r+[x_mu(maxix), y_mu(maxix)];
    if length(pm_tmp)>2
        pm(3)=coords(maxix,3);
    end
    Mused=dip_image(Mstack(:,:,sigix));
    
    nphot_max=(maxi-offsetphot)*2*pi*musigix; %number pf photons emited by brughtest source
end
end

function [mean_bg, var_bg, bg_im] = chooseregion(im, bg_im)
again = 1;
H = figure;
perc_thresh = 50;
count = 1;
while again
    pt(count)=perc_thresh;
    il=im(bg_im); %linear version
    maxil = max(abs(il));
    meanil = mean(il);
    ilthresh = (maxil-meanil)/100*perc_thresh;
    ix = find(abs(il-meanil)<ilthresh);
    figure(H);
    subplot(3,2,[1 2])
    hold off
    plot((abs(il-meanil)>ilthresh)*maxil,'r')
    hold on
    plot(il)
    hline2(ilthresh+meanil)
    hold off
    subplot(3,2,[3 4])
    plot(il(ix))
    grid on
    mean_bg = mean(il(ix));
    var_bg = var(il(ix));
    hline2(mean_bg, '-r','mean')
    hline2(-sqrt(var_bg)+mean_bg, '--r','-sqrt(var)')
    hline2(sqrt(var_bg)+mean_bg, '--r','sqrt(var)')
    %     hline2([-sqrt(var_bg), sqrt(var_bg)]+mean_bg,
    %     {'--r','--r'},{'-sqrt(var)', '-sqrt(var)'})
    subplot(3,2,5)
    %     hist(double(il(ix)),100)
    hold off
    [h, xh] = hist(double(il(ix).*mean_bg./var_bg),100);
    ixh = find(h>0);
    [maxh maxhpos]=max(h);
    %[pbest,perror,nchi]=nonlinft('poissoncontinuos' ,xh(ixh),h(ixh)/sum(h(ixh)),sum(h(ixh))./h(ixh),[xh(maxhpos) 1],[1 1])
    [pbest,perror,nchi(count)]=nonlinft('poissoncontinuos' ,xh(ixh),h(ixh)/sum(h(ixh)),ones(size(h(ixh))),[xh(maxhpos) 1],[1 1])
    %[pbest,perror,nchi]=nonlinft('poissoncontinuos' ,xh(ixh),h(ixh)/sum(h(ixh)),sum(h(ixh))./h(ixh),[xh(maxhpos)],[1])
    bar(xh(ixh),h(ixh)/sum(h(ixh)))
    hold on
    plot(xh(ixh), poissoncontinuos(xh(ixh),pbest),'r')
    hold off
    grid on
    subplot(3,2,6)
    stem(pt, nchi)
    [minnchi, minnchipos] = min(nchi);
    vline2(pt(minnchipos),'r',num2str(pt(minnchipos)))
    grid on
    fprintf('Estimated backgound %g\n', mean_bg)
    fprintf('Estimated variance backgound %g\n', var_bg)
    fprintf('Threshold is %g %%.\n',perc_thresh)
    fprintf('Minimum nchi is for %g %%.\n',pt(minnchipos))
    R = input ('OK? [y/n] \n','s');
    if strcmp(R,'n')
        perc_thresh = input ('Threshold constant? [%] \n');
    else
        again=0;
    end
    count=count+1;
end
i1=find(bg_im);
bg_im = newim(bg_im);
bg_im(i1(squeeze(ix+1)))=1;
end