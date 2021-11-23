clear
offset=100;
p.NA = 1.3;
p.lambda = 655;
p.pixelsize = 106;
p.method = 'airy';
psf_odd = psfgen('lambda', p.lambda, 'na', p.NA, 'pixelsize', p.pixelsize, 'sizevec', [11 11], 'method', p.method);
p.nx=15;
p.ny=15;
p.N=20;
p.np=1000;
p.niter = 1;

p.Nt=1000;
p.ox = 3; %margin...
p.oy = 3;

comment = []; 
p.prename = 'D';
p.path = '~/project/data/qdots/D/';

for jj = 1: length(offset)
    p.namedir = [p.prename 'long_N' num2str(p.N) '_offset' num2str(offset(jj))];
    mkdir ([p.path p.namedir]);
    cd ([p.path p.namedir])
    p.offset = offset(jj);
    writedata ([],[],p,p.namedir,comment)
    for kk = 1:p.niter
        x_vec = p.ox+(p.nx-2*p.ox)*rand(1,p.N);
        y_vec = p.oy+(p.ny-2*p.oy)*rand(1,p.N);
        p.x_vec = x_vec;
        p.y_vec = y_vec;
        [dpixc, dpixc_ind, blinkmat] = generatedataMulti([0 p.nx 0 p.ny], x_vec,y_vec,p.np+10*rand(1,p.N),psf_odd,p.offset,p.Nt);
        save ([p.namedir '_iter' num2str(kk)])
    end
end