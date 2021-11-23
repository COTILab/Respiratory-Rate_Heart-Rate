clear
% data simulation
p.sizevec = [0 32, 0 32];
p.nx = p.sizevec(2)-p.sizevec(1);
p.ny = p.sizevec(4)-p.sizevec(3);

p.lambda = 655; %nm
p.pixelsize = 106; %in nm after resizing...
p.lambdapix = p.lambda/p.pixelsize; %pixels
p.NA = 1.3;
% p.broadenfactor = 3; %NA is not really that good
p.broadenfactor = 1;

p.s = p.broadenfactor*1.4/(2*pi)*(p.lambdapix/p.NA); %gaussian approx of airy
% s = 1/rs*s; %for before resizing...

[X, Y] = meshgrid(-20:20);
psf = exp(-(X.^2+Y.^2)/(2*p.s^2));
psf = psf / sum(psf(:));

% sep = [0.1 0.2 0.5 1 1.5 2];
% sep = [0.3 0.4 0.6 0.8 0.9 1.2 1.7];
% offset = [2, 10];
% sep = [.1 .2 .3 .4 .5 .6 .8 .9 1 1.2 1.5 1.7 2 2.2 2.4 2.6 2.8 3.0];
% sep = [4 5 6 7 8 9 10];
% sep = [0.2:0.2:3, 4:10];
offset = [10 100 1000];

sep = [0.1 :0.1 : 1];

p.niter = 10;
p.Nt = 500;
p.maxphotvec = [10000 10000];

comment = [];
p.prename = 'S44_sep_';
p.path = '~/project/data/qdots/S44/';

for jj = 1: length(offset)
    fprintf('\n %g:' ,jj)
    for ii=1 : length(sep)
        fprintf('.')
        p.namedir = [p.prename num2str(100*sep(ii)) 'offset_' num2str(offset(jj))];
        mkdir ([p.path p.namedir]);
        cd ([p.path p.namedir])
        %         ims(psf);
        %         SaveImageFULL('psf', 'pf');
        p.separ = [sep(ii) 0]; %shif tin one dimension only
        p.offset = offset(jj);
        writedata ([],[],p,p.namedir,comment)
        for kk = 1:p.niter
            [dpixc, dveccr, dpixc_ind, blinkmat, N] = generatedata2(p.sizevec, psf, p.separ, p.maxphotvec, p.offset, p.Nt);
            save ([p.namedir '-iter_' num2str(kk)])
        end
    end
end