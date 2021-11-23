function f = ddivHexp(Hkt_r, varargin)
% function f = ddivH(Hkt_r, varargin)
% Hkt_r = reshape(Hkt,1,k*t) -> row vector
% Vxt = varargin{1};  %data
% Wxk_exp = varargin{2};  %W matrix
% Wxk_fix = varargin{3}; %fixed part of the Wxk matrix (e.g. background) ->rows
% Hkt_fix = varargin{4}; %fixed part (lines) of the H matrix (e.g. background)

Vxt = varargin{1};      %data
Wxk_tmp = varargin{2};  %W matrix
Wxk_fix = varargin{3};  %fixed part of the Wxk matrix (e.g. background) ->rows
Hkt_fix = varargin{4};  %fixed part (lines) of the H matrix (e.g. background)
peval = varargin{5}; %parameters

if ~isfield(peval, 'w_lambda') peval.w_lambda=0; end

t=size(Vxt,2);
k=length(peval.h_dovec);

Hkt_tmp = exp(reshape(Hkt_r,k,t));

Wxk = zeros(peval.numpix, peval.ncomp+1);
Hkt = zeros(peval.ncomp+1, peval.nt);

Wxk(:,peval.w_dovec)=Wxk_tmp;
Hkt(peval.h_dovec,:)=Hkt_tmp;

Wxk(:,peval.w_fixvec)=Wxk_fix;
Hkt(peval.h_fixvec,:)=Hkt_fix;

% fxt = (Vxt.*log(Vxt./(Wxk*Hkt))-Vxt+Wxk*Hkt); %d-divergence 
% f = sum(fxt(:));
f = ddivergence(Vxt,Wxk*Hkt);