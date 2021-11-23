function d = loglikelihoodPoisson(A,B)
% d = loglikelihoodPoisson(A,B)
% For NMF: A=data, B=model
if sum(A(:)<=0)
    fprintf('Clipping negative values in A!\n')
    A(A<=0)=eps; % to avoid negative values and zeros...
end
if sum(B(:)<=0)
    fprintf('Clipping negative values in B!\n')
    B(B<=0)=eps; % to avoid negative values and zeros...
end
    dm = A .* log (B) - B - (A.*log(A)-A); %stirling approximation of log(A!)
    d = sum(dm(:));
end