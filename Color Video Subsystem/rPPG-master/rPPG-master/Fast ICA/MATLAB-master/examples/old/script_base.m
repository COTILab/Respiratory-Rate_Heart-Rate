
close all
tstart=tic;
addpath '~/project/MATLAB/PatternAnalysis/'
addpath '~/project/MATLAB/qdots/'
addpath '~/project/MATLAB/qdots/FastICA_25/'
% Nt = [100, 500, 1000, 5000];
Nt = 1000;
rs = 0.25; %resizing faction
sizevec = [0 32, 0 32];
nx = sizevec(2)-sizevec(1);
ny = sizevec(4)-sizevec(3);

center = ceil([nx, ny]/2);
d = [center; center + [1 0]];


lambda = 400; %nm
pixelsize = 106*rs; %in nm after resizing... 
lambdapix = lambda/pixelsize; %pixels
NA = 1.0;
s = 1.4/(2*pi)*(lambdapix/NA); %gaussian approx of airy
% s = 1/rs*s; %for before resizing...

[X, Y] = meshgrid(-20:20);
psf = exp( -(X.^2+Y.^2)/(2*s^2) );
psf = psf / sum(psf(:));

maxphot = 100; % maximal expexted number of photons in one pixel 
%  photcount = 100; %mabe made it such that sum(psf(:))=photcount...
offset = 0.01; % general offset as a fraction of maximum
meth = {'ica', 'nmf'};
path = [];
for ii = 1:4
    [dpixc, dveccr, N] = generatedata(d, sizevec, psf, maxphot, offset, Nt(ii), rs);
    n = num2str(ii);
    imstiled(dpixc(:,:,1:12));
    SaveImageFULL(['dpixc_' n], 'p')
    numOfIC = N;
    for jj = 1:2
        if jj==1
            [icasig, A, W] = fastica (dveccr, 'numOfIC', numOfIC, 'g', 'tanh');
            sica = size(A,2);
            icapix = reshape(A,nx*rs, ny*rs, sica);
        else
            [w,h]=nmf(dveccr',numOfIC,1);
            icapix=shiftdim(reshape(h,numOfIC,nx*rs,ny*rs), 1);
        end
        name = [n '_' meth{jj}];
        comp_images(icapix, dpixc, d, rs, saveon, name, path)
    end
    
end