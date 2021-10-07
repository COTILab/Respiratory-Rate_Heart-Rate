function [recon_signal,imf,info,residual,imf_idx_1,imf_idx_2]= EMD_Analysis(orig_signal,varargin)
%% Written on 15SEP21
% INPUTS
% 1.Orig_signal: Raw Signal to reconstruct
% OPTIONAL ARGUMENTS: [IMF1_IDX, IMF2_IDX]; Which IMFs do we sum together
%: 3.sift_tol: Terminaton Criterion
% to reconstruct primary signal

% OUTPUT
%[recon_signal]==> sum of specified IMF components

if length(varargin)==2
    imf_idx_1=varargin{1};
    imf_idx_2=varargin{2};
    sift_tol=0.2;
end

if length(varargin)>2
    sift_tol=varargin{3};
end

if length(varargin)<2
    sift_tol=0.2; % default
end

[imf,residual,info] = emd(orig_signal,'SiftRelativeTolerance',sift_tol); disp("SPLINED EMD")
if length(varargin)==0 % no external arguments--default
    imf_idx_1=1; % which IMF do we want to use
    imf_idx_2=size(imf,2); % imf end
    
end
imf_chosen=imf(:,imf_idx_1:imf_idx_2);
%imf_chosen=imf(:,(en-1):end);

recon_signal=sum(imf_chosen,2);


end


