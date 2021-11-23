function [varargout, peval] = separcomp(dpix, peval, winit_pix, hinit)
% separcomp(dpix, p_script, savethis, winit, hinit)
% separate components
% V ~ WH
% V -> N_pix x N_t
% W -> N_pix x N_comp - xth pixel of the ith components
% H -> N_copm x N_t - contribution of the i-th component in the time t

[peval.nx, peval.ny, peval.nt] = size(dpix);
peval.numpix = peval.nx*peval.ny;
peval.meandata = mean(dpix(:));

dvec = reshape(dpix,peval.numpix, peval.nt);
dpix_dip = dip_image(dpix);

% background subtraction with empirical values:
peval.bg_clip = 'no'; 
peval.bg_fs_var = 5; 
peval.bg_perc = 20; 
peval.bg_ob_dist = 8;
if ~isfield(peval, 'bg')
    [out_nobg, peval.bg, bg_im]=backgroundoffset(dpix_dip, peval.bg_clip, peval.bg_fs_var, peval.bg_perc, peval.bg_ob_dist);
end

if ~isfield(peval, 'ncomp')
    peval.ncomp=estimate_ncpomp(dvec);
end

[winit, hinit] = initwh(winit_pix, hinit, peval); %initialization of w and h



if ~isfield(peval, 'w_fixvec') peval.w_fixvec=[]; end
if ~isfield(peval, 'h_fixvec') peval.h_fixvec=[]; end

if isempty(peval.w_fixvec)
    peval.w_fixvec = peval.ncomp + 1; %fixing background component
elseif ~(peval.w_fixvec(end) == peval.ncomp + 1)
    peval.w_fixvec = [peval.w_fixvec, peval.ncomp + 1];
end

if isempty(peval.h_fixvec)
    peval.h_fixvec = peval.ncomp + 1; %fixing background component
elseif ~(peval.h_fixvec(end) == peval.ncomp + 1)
    peval.h_fixvec = [peval.h_fixvec, peval.ncomp + 1];
end

verbose = 1;
if strcmp (peval.method, 'nmf_classic') %classical nmf updates
    fprintf('!!!test!!!')
    [w,h,peval, dtrace, htrace]=nmf_classic_test(dvec,winit,hinit,peval,verbose);
elseif strcmp (peval.method, 'nmf_conjgrad_test2') %classical nmf updates
    peval.nt_all=peval.nt;
    peval.nt=1;
    h=zeros(size(hinit));
    htrace = zeros(peval.maxh+1, peval.ncomp, peval.nt_all);
    for tt=1:peval.nt_all;       
        [w,h(:,tt),peval,dtrace1, htrace(:,:,tt)]=nmf_conjgrad(dvec(:,tt),winit,hinit(:,tt),peval,verbose);        
    end
end
for ii=1:size(htrace,1)
    hii = [exp(squeeze(htrace(ii,:,:))); h(peval.ncomp+1,:)];
    dtrace(ii)= ddivergence(dvec, w*hii);
end
varargout = struct('w',w,'h',h, 'dtrace', dtrace, 'htrace', htrace);