function [imphot, bg_im nphot_max, offsetphot, sig, pm] = getimpar(im);
%[imphot, bg_im, nphot_max, offsetphot, sig, pm] = getimpar(im);
%assuming poisson noise only, convert image so that intensity correspond to
%number of photons (var = mean for background...)

[out_nobg, bg, bg_im]=backgroundoffset(im, 'no', 5, 20, 20);
sumbg=sum(im,bg_im);
offset=mean(im,bg_im);
v=sum((im-offset).^2,bg_im);
ncoef=sumbg/v;
imphot=im*ncoef;
offsetphot=offset*ncoef;

[maxi, pm]=max(imphot);
r=5; %size of ROI
if length(pm)==2
    M=double(imphot(pm(1)-r:pm(1)+r,pm(2)-r:pm(2)+r));
elseif length(pm)==3
    M=double(squeeze(imphot(pm(1)-r:pm(1)+r,pm(2)-r:pm(2)+r, pm(3))));
end
[x_mu, y_mu, sig] = fitgauss2d(M-offsetphot);


nphot_max=(maxi-offsetphot)*2*pi*sig;

