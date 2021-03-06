function [S,A,ll,Tau]=icaMS(X,Tau,draw)
% icaMS     : Dynamic ICA by the Molgedey and Schuster decorrelation algorithm.
%
% function [S,A,ll,Tau]=icaMS(X,[Tau],[draw])   Independent component analysis (ICA) using the
%                                               Molgedey and Schuster decorrelation algorithm, 
%                                               having square mixing matrix and no noise [1].  
%                                               Truncation is used for the time shifted matrix,
%                                               and ensured to be symmetrix [2]. The delay Tau 
%                                               is estimated using autocorrelation differences
%                                               [3]. NB! signals X must have zero mean .
%                                       
%                                               X   : Zero mean mixed signals
%                                               Tau : Fixed value of the delay Tau or Tau=0 for
%                                                     automatic estimating the dalay. Default 
%                                                     value is Tau=0.
%                                               draw: Output run-time information if draw=1. 
%                                                     Default draw=0.
%                                       
%                                               A   : Esitmated mixing matrix.
%                                               S   : Estimated source signals with variance 
%                                                     scaled to one.
%                                               ll  : Log likelihood for estimated sources.
%                                               Tau : Estimated value of Tau. 
%                                       
% - by Thomas Kolenda 2002 - IMM, Technical University of Denmark
% - version 1.3

% Bibtex references:
% [1]  
%   @article{Molgedy.sep94,
%       author       = "L. Molgedey and H. Schuster",
%       title        = "Separation of independent Signals using Time-Delayed Correlations",
%       journal      = "Physical Review Letters",
%       volume       = "72",
%       number       = "23",
%       pages        = "3634-3637",
%       year         = "1994",
%   }
%
% [2]
%   @book{Hansen2000.MM,
%       author       = "Hansen, L. K. and Larsen, J. and Kolenda, T.",
%       title        = "On Independent Component Analysis for Multimedia Signals",
%       booktitle    = "Multimedia Image and VideoProcessing",
%       editor       = "L. Guan, S.Y. Kung and J. Larsen",
%       publisher    = "CRC Press",
%       year         = "2000",
%       url          = "http://www.imm.dtu.dk/pubdb/views/edoc_download.php/627/pdf/imm627.pdf",
%   }
%
% [3]
%   @article{Kolenda.ica01,
%       author       = "T. Kolenda and L.K. Hansen and J. Larsen",
%       title        = "Signal Detection using ICA: Application to Chat Room Topic Spotting",
%       journal      = "In proc. ICA'2001",
%       volume       = "5",
%       pages        = "3197--3200",
%       year         = "2001",  
%       url          = "http://www.imm.dtu.dk/pubdb/views/edoc_download.php/827/pdf/imm827.pdf", 
%   }


if nargin<2,
    Tau=0;
end

if nargin<3,
    draw=0;
end


if Tau==0,
    AutoTau=1;
    Tau=1;
else
    AutoTau=0;
end

[K,N]=size(X);


% estimate MS ICA for given delay tau
% [S,A]=molgedey(X,1);
[S,A]=molgedey(X,Tau);

% re-estimate MS ICA for estimated tau
if AutoTau==1,
    ite=0;
    preTau=0;
    while (preTau~=Tau) & (ite<=10),
        ite=ite+1;
        preTau=Tau;
        
        Tau=findtau(S,1:round(length(S)*.5),draw);
        [S,A]=molgedey(X,Tau);
        if draw==1, disp(sprintf('Determine tau: ite:%d  tau:%d',ite,Tau)); end;
        
    end
    
    if preTau~=Tau,
        if draw==1, disp(sprintf('Warning - Stabel value for Tau could not be found !  tau:%d',Tau)); end;
    end
end

% sort components according to energy
Avar=diag(A'*A)/K;
Svar=diag(S*S')/N;
vS=var(S');
sig=Avar.*Svar;
[a,indx]=sort(sig);
S=S(indx(K:-1:1),:);
A=A(:,indx(K:-1:1));


% log likelihood
if nargout>2,
    logP=-N*log(abs(det(A))) - 0.5*N*K*log(2*pi) - 0.5*N*K;
    for j=1:K,
        R(j,:)=xcov(S(j,:))/N;
        Sig=toeplitz(R(j,N:end));    
        logP=logP - sum(log(diag(chol(Sig))));  
    end
    ll=logP;
end


function [S,A,autos]=molgedey(X,tau)
% Dynamic ICA by the Molgedey and Schuster decorrelation algorithm for a specific Tau.

% build upper part of quotient matrix
Mb=X(:,tau+1:end)*X(:,1:end-tau)'; % Truncate at matrix border
Mb=0.5*(Mb+Mb'); % Ensure symmetri

% build lower part of quotient matrix
M=X*X';       

try 
    % quotient matrix
    
    Q=Mb*pinv(M);
    
    % eigenvalue decomp
    [A,L]=eig(Q); 
    
    % estimated unmixing matrix and sources
    W =inv(A);
    S=W*X;
    
    % variance one for sources
    A=A.*repmat(std(S'),size(A,1),1);
    S=S./repmat(std(S')',1,size(S,2));
    
catch
    disp('Warning - Problems solving MS ICA !');
    A=[];
    S=[];
end

function tau=findtau(S,searchTauDist,draw)
% Find delay Tau based on the largest difference in the source autocorrelations.

% autocorrelation functions
for i=1:size(S,1),
    X(i,:)=xcorr(S(i,:),S(i,:),'coeff');
end

% get search interval of summetric autocorrelation functions
indx=(size(X,2)-1)/2+2:size(X,2);
X=X(:,indx);
N=searchTauDist;

if size(X,1)>1,
    
    if draw==1,
        subplot(2,1,1)
        plot(N,real(X(:,N)))
        ylabel('\gamma_{X}')
        xlabel('\tau')
    end
    
    
    % distance between components
    Xm=sort(X);
    Xm=(Xm-min(min(Xm)))/(max(max(Xm-min(min(Xm))))); % min 0 and max 1
    for i=1:size(Xm,1)-1,
        d(i,:)=Xm(i+1,:)-Xm(i,:);
    end
    
    % largst sum distance between components for a given tau
    dm=1/(size(X,1)-1);
    d=sum(abs(d-dm),1);
    [value,tau]=sort(d(N));
    
    if draw==1,
        subplot(2,1,2)
        plot(N,d(N)','-r')
        xlabel('\tau')
        ylabel('dist')
    end
    
    % select largest
    tau=tau(1);
else
    tau=1;
    if draw==1, disp(sprintf('Tau not estimated,  set tau=%i',tau)); end;
end




