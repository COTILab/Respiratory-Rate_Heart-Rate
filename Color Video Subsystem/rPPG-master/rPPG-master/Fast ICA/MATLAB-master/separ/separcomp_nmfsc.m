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
% if strcmp (peval.method, 'nmf_classic') %classical nmf updates    
%     [w,h,peval, dtrace, htrace]=nmf_classic(dvec,winit,hinit,peval,verbose);
% elseif strcmp (peval.method, 'nmf_conjgrad') %classical nmf updates
%     [w,h,peval, dtrace, htrace]=nmf_conjgrad(dvec,winit,hinit,peval,verbose);
% end
[w,h] = nmfsc( dvec, peval.ncomp, peval.spars_w, [], 'smaz2', 1 )
%better with feval....
varargout = struct('w',w,'h',h);