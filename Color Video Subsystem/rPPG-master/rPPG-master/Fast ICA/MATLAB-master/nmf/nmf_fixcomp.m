function varargout=nmf_fixcomp(v,winit,hinit,w_fixvec,h_fixvec,peval,verbose)
%
% Jean-Philippe Brunet
% Cancer Genomics
% The Broad Institute
% brunet@broad.mit.edu
%
% This software and its documentation are copyright 2004 by the
% Broad Institute/Massachusetts Institute of Technology. All rights are reserved.
% This software is supplied without any warranty or guaranteed support whatsoever.
% Neither the Broad Institute nor MIT can not be responsible for its use, misuse,
% or functionality.
%
% NMF divergence update equations :
% Lee, D..D., and Seung, H.S., (2001), 'Algorithms for Non-negative Matrix
% Factorization', Adv. Neural Info. Proc. Syst. 13, 556-562.
%
% v (n,m) : N (genes) x M (samples) original matrix
%           Numerical data only.
%           Must be non negative.
%           Not all entries in a row can be 0. If so, add a small constant to the
%           matrix, eg.v+0.01*min(min(v)),and restart.
%
% r       : number of desired factors (rank of the factorization)
%
% verbose : prints iteration count and changes in connectivity matrix elements
%           unless verbose is 0
%
% Note : NMF iterations stop when connectivity matrix has not changed
%        for 10*stopconv interations. This is experimental and can be
%        adjusted.
%
% w    : N x r NMF factor
% h    : r x M NMF factor
%
% winit - initial value for w
% hinit - initial value for h
% h_fixvec & w_fixvec:
% fixvec - binary vector which component should be fixed: eg [2 3] will
% fix second and third component while varying the first...

fprintf('Classic NMF iterations\n')
% test for negative values in v
if min(min(v)) < 0
    error('matrix entries can not be negative');
    return
end
if min(sum(v,2)) == 0
    error('not all entries in a row can be zero');
    return
end

[n,m]=size(v);

if ~isempty(w_fixvec)
    fprintf('Fixing [ ');
    fprintf('%g ', w_fixvec);
    fprintf('] component of ''w''\n');
end

if ~isempty(h_fixvec)
    fprintf('Fixing [ ');
    fprintf('%g ', h_fixvec);
    fprintf('] component of ''h''\n');
end

peval.niter = 1000;
w = winit;
h = hinit;

d(1) = ddivergence(v, w*h);
dterm = 1; %can be changed

w_vec = 1:size(w,2);
w_dovec = find(~(w_vec==w_fixvec));

h_vec = 1:size(h,1);
h_dovec = find(~(h_vec==h_fixvec));


for ii=2:peval.niter
    
    w_old = w;
    h_old = h;
        
    x1=repmat(sum(w,1)',1,m);
    y1=w'*(v./(w*h));
    h(h_dovec,:)=h(h_dovec,:).*(y1(h_dovec,:))./x1(h_dovec,:);
    h=max(h,eps); % adjust small values to avoid undeflow
    
    x2=repmat(sum(h,2)',n,1);
    y2=(v./(w*h))*h';
    w(:,w_dovec)=w(:,w_dovec).*(y2(:,w_dovec))./x2(:,w_dovec);
    w=max(w,eps); % adjust small values to avoid undeflow
        
    % normalization of all h:
    sumw = sum(w,1);
    w = w./repmat(sumw,n,1); %normalization of each component
    h = h.*repmat(sumw',1,m); %to keep the multiplication equal
    
%     wtrace(:,:,ii) = w;
%     htrace(:,:,ii) = h;
     
    d(ii) = ddivergence(v, w*h);
    dd(ii) = abs(d(ii)-d(ii-1));
    if dd(ii) < dterm
        break
    end    
    if verbose
        fprintf('Cycle %g D-divergence %g\n',ii-1,d(ii))
    end
end

peval.maxiter = ii;
peval.maxiter_reached_flag = 0;
if ii == peval.niter
    fprintf('\nMAximum number of iteration (%g) reached! \n', peval.niter)
    peval.maxiter_reached_flag = 1;
end

varargout{1}=w;
varargout{2}=h;
varargout{3}=peval;