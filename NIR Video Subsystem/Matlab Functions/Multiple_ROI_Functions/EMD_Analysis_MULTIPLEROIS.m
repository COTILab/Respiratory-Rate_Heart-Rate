function [recon_signal,imf,info,residual,imf_idx_1,imf_idx_2]= EMD_Analysis_MULTIPLEROIS(all_orig_signal,varargin)
%% Written on 15SEP21
% INPUTS
% 1.Orig_signal: Raw Signal to reconstruct
% OPTIONAL ARGUMENTS: [IMF1_IDX, IMF2_IDX]; Which IMFs do we sum together
%: 3.sift_tol: Terminaton Criterion
% to reconstruct primary signal

% OUTPUT
%[recon_signal]==> sum of specified IMF components
for i=1:length(all_orig_signal) % for each bbox
    orig_signal=all_orig_signal{i};
    
if length(varargin{1}{1})==2
    imf_idx_1{i}=varargin{1}{i}(1);
    imf_idx_2{i}=varargin{1}{i}(2);
    %sift_tol=0.2;
end

if length(varargin{1}{1})>2
    sift_tol=varargin{1}{i}{3};
end

if length(varargin{1}{1})<3
    sift_tol=0.2; % default
end

[imf{i},residual{i},info{i}] = emd(orig_signal,'SiftRelativeTolerance',sift_tol); %disp("SPLINED EMD")

if isnan(imf_idx_2{i})==1
     imf_idx_2{i}=size(imf{i},2); % MASKING NANs to be size of array
end

if length(varargin)==0 % no external arguments--default
    imf_idx_1{i}=1; % which IMF do we want to use
    imf_idx_2{i}=size(imf{i},2); % imf end
    
end
imf_chosen=imf{i}(:,imf_idx_1{i}:imf_idx_2{i});
%imf_chosen=imf(:,(en-1):end);

recon_signal{i}=sum(imf_chosen,2);

end
end


