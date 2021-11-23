function [bic, loglik, penalty] = computebic(pathname, filename, ncomp_vec, dpixc, penalty_type)
% [bic, loglik, penalty] = computebic(pathname, filename, ncomp_vec, dpixc, penalty_type)
% penalty_type = 1 : original NMF
% penalty_type = 2 : original NMF + multidimensinoal data
% penalty_type = 3 : hidden + multidimensinoal data

if ~exist('penalty_type','var')
    penalty_type = 1;
end

for ii=1:length(ncomp_vec)
%     if strcmp(pathname(end), '/')
%         load ([pathname filename num2str(ncomp_vec(ii))])
%     else
%         load ([pathname '/' filename num2str(ncomp_vec(ii))])
%     end
%     load ([pathname filename num2str(ncomp_vec(ii)) '/' filename num2str(ncomp_vec(ii))]);
    load ([pathname '/' filename num2str(ncomp_vec(ii))]);
    loglik(ii) = -ddivergence(reshape(dpixc,peval.numpix, peval.nt),res.w*res.h);
    switch penalty_type
        case 1 % orig
            if ii==1 fprintf ('Penalty: original NMF\n'); end
            penalty(ii) = 0.5*peval.ncomp*(peval.nt+peval.numpix)*log(peval.nt*peval.numpix); %orig
        case 2 % orig + multidiensional data
            if ii==1 fprintf ('Penalty: original NMF + multidimensional data\n'); end
            penalty(ii) = 0.5*peval.ncomp*(peval.nt+peval.numpix)*log(peval.nt);
        case 3 % hidden + multidimensional data
            if ii==1 fprintf ('Penalty: multidimensional + hidden\n'); end
            penalty(ii) = 0.5*peval.ncomp*(peval.numpix)*log(peval.nt);
    end
            
            
% penalty(ii) = 0.5*peval.ncomp*(peval.nt+peval.numpix)*log(peval.nt*peval.numpix);    
% penalty(ii) = 0.5*peval.ncomp*(peval.nt+peval.numpix)*log(peval.nt*peval.numpix); %orig
% penalty(ii) = 0.5*peval.ncomp*(peval.numpix)*log(peval.nt); %hidden +
% multidimensional data
% penalty(ii) = 0.5*peval.ncomp*(peval.nt+peval.numpix)*log(peval.nt); % orig + multidiensional data

%     bic(ii) = -ddivergence(reshape(dpixc,peval.numpix, peval.nt),res.w*res.h) - 0.5*peval.ncomp*peval.nt*log(peval.nt*peval.numpix); 
end
bic =  loglik - penalty;