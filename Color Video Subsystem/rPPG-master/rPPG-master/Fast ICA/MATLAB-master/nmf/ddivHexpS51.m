function f = ddivHexpS51(Hkt_r, varargin)
% function f = ddivH(Hkt_r, varargin)
% Hkt_r = reshape(Hkt,1,k*t) -> row vector
% Vxt = varargin{1};  %data
% Wxk_exp = varargin{2};  %W matrix
% Wxk_fix = varargin{3}; %fixed part of the Wxk matrix (e.g. background) ->rows
% Hkt_fix = varargin{4}; %fixed part (lines) of the H matrix (e.g. background)


Vxt = varargin{1};  %data
Wxk_tmp = varargin{2};  %W matrix
Wxk_fix = varargin{3}; %fixed part of the Wxk matrix (e.g. background) ->rows
Hkt_fix = varargin{4}; %fixed part (lines) of the H matrix (e.g. background)

t=size(Vxt,2);
k=size(Wxk_tmp,2);
Hkt = [exp(reshape(Hkt_r,k,t)); Hkt_fix];
Wxk = [Wxk_tmp, Wxk_fix];

fxt = (Vxt.*log(Vxt./(Wxk*Hkt))-Vxt+Wxk*Hkt); %d-divergence 
f = sum(fxt(:));