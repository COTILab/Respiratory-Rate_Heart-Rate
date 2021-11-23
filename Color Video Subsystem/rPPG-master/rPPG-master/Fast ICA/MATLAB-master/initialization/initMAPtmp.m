function [x,y, hinit, peval] = initMAP(dpixc, peval)
% [x,y, hinit, peval] = initMAP(dpixc, peval)
% Initializaion of the position of the W and H. 
% peval.winitmethod = 'SampleFromMean' (default) initialize positons of W
% as a sample from the distriburion defined by the mean(dpixc,3)
% peval.winitmethod = 'MaxMean' initialize position of W as a maximum of
% the mean(dpixc, 3)
% peval.winitjitter -> adds jitter to the position when peval.winitmethod =
% MaxMean;

if ~isfield(peval, 'winitmethod')
    fprintf('Assigned default value: peval.winitmethod=''SampleFromMean''\n')
    peval.winitmethod = 'SampleFromMean';
end
    
peval.meandata = mean(dpixc(:));
        image=mean(dpixc,3);
        
switch lower(peval.winitmethod);
    case 'samplefrommean'
        fprintf('Position of W initialized as a sample from distribuion defined by mean(dpixc,3)\n')
        [x,y]=sample2d(image,peval.ncomp);
    case 'maxmean'
        fprintf('Position of W initialized at the maximum of mean(dpixc,3)\n')
        m=mean(dpixc,3);
        [x1,y1]=find(m==max(m(:)));
        x=repmat(x1, 1,peval.ncomp);
        y=repmat(y1, 1, peval.ncomp);
        if isfield(peval,'winitjitter') % adds jitter +-peval.initwjitter
            fprintf('Jitter %f added to the initial positon of the W\n', peval.winitjitter)            
            x=x+peval.winitjitter*(rand(size(x))-.5);
            y=y+peval.winitjitter*(rand(size(y))-.5);
            
        end
    otherwise
            error('peval.winitmethod not recognized!')
end
            

hinit = rand(peval.ncomp, size(dpixc,3));
winit_pix_tmp=gauss2dmultislice([peval.nx, peval.ny, peval.ncomp], [x',y']+1, peval.sigmaPSF, 1);
winit_pix = normalizeslices(winit_pix_tmp);[winit, hinit] = initwh(winit_pix, hinit, peval); %initialization of w and h