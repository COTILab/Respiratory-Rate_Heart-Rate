% NMFLAB for Signal Processing written by A. Cichocki and R. Zdunek 
% in cooperation with other members of Laboratory for Advanced Brain Signal
% Processing, BSI, RIKEN, Saitama, JAPAN

function [A,X,Distance_output]=nmf_newton(Y,r,Index_norm,A_true,S, mc_on, NoAlts,restart_mc_on,AL,Y_true,type_alg_A,type_alg_X,max_restart,no_iter,alphaS,alpha,CostFun,lambda,alpha0,tau)
%
% Non-negative Matrix Factorization (NMF) with the quasi-Newton method
%
%
% [A,X]=nmf_newton(Y,r,Index_norm,A_true,S,mc_on,NoAlts,restart_mc_on,AL,Y_true,type_alg_A,type_alg_X,max_restart,no_iter,alphaS,alpha,L_type,lambda,alpha0,tau)
% 
%       produces mixing matrix A of dimension [m by r],
%       and source matrix X of dimension [r by T], for the linear mixing model: AX = Y, 
%       where Y is an observation matrix [m by T]. 
% Note: > m: number of sensors,
%       > r: number of sources,
%       > T: number of samples,
% 
% INPUTS:
%       > Index_norm:    vector of 13 binary entries indicating which number
%                        divergence measures are turned on in the View Options,
%       > A_true:        true mixing matrix (only for synthetic data),
%       > S:             true source matrix (only for synthetic data), 
%       > mc_on:         1 - Monte Carlo analysis enabled, 0 - otherwise, 
%       > NoAlts:        number of alternating steps (only for Monte Carlo
%                        analysis and the option "Fixed Alternatings" is selected)
%       > restart_mc_on: 1 - restarts in Monte Carlo analysis are enabled,
%                        0 - otherwise, 
%       > AL:            mixing matrix estimaed from the preceeding layer, 
%       > Y_true:        the first layer mixed signals (mixtures),
%       > type_alg_A:    indicates the selected algorithm for computation
%                        of the mixing matrix,
%       > type_alg_X:    indicates the selected algorithm for computation of the sources,  
%       > no_iter:       number of inner iterations, 
%       > alphaS:        parameter of non-linear projection in computation
%                        of the sources, 
%       > alpha:         parameter "alpha" in the alpha-divergence,
%       > CostFun        cost function: (1) - Euclidean, 
%                                       (2) - alpha-divergence
%       > lambda         Tikhonov regularization parameter in QP-NMF
%       > alpha0:        initial magnitude in the exponential model for regularization parameter,
%       > tau:           damping factor in the exponential model for regularization parameter,
% 
% OUTPUTS:
%       > A:               estimated mixing matrix,
%       > X:               estimated source matrix,
%       > Distance_output: structures of different divergences measured between "Y" and estimated "AX" versus iterations,
%
% #########################################################################
A = [];
X = [];
if (nargin < 20) | isempty(tau) | max(size(tau) > 1)
   disp('Incorrect the damping factor in the exponential model');
   return
end
if (nargin < 19) | isempty(alpha0) | max(size(alpha0) > 1)
   disp('Incorrect the initial magnitude in the exponential model');
   return
end
if (nargin < 18) | isempty(lambda) | max(size(lambda) > 1)
   disp('Incorrect regularization parameter');
   return
end
if (nargin < 17) | isempty(CostFun) | (CostFun < 1) | max(size(CostFun) > 1)
   disp('Incorrect cost function');
   return
end
if (nargin < 16) | isempty(alpha) | max(size(alpha) > 1)
   disp('Incorrect parameter alpha in alpha-divergence');
   return
end
if (nargin < 15) | isempty(alphaS) | max(size(alphaS) > 1)
   disp('Incorrect parameter alphaS');
   return
end
if (nargin < 14) | isempty(no_iter)  | (no_iter < 0) | max(size(no_iter) > 1)
   disp('Incorrect number of inner iterations');
   return
end
if (nargin < 13) | isempty(max_restart)  | (max_restart < 0) | max(size(max_restart) > 1)
   disp('Number of restarts must be given correctly');
   return
end
if (nargin < 12) | isempty(type_alg_X) | (type_alg_X < 1) | max(size(type_alg_X) > 1)
   disp('Incorrect algorithm for X');
   return
end
if (nargin < 11) | isempty(type_alg_A) | (type_alg_A < 1) | max(size(type_alg_A) > 1)
   disp('Incorrect algorithm for A');
   return
end
if (nargin < 10) | isempty(Y_true) 
   disp('The first layer mixed signals are unknown');
   Y_true = zeros(size(Y_true));
end
if (nargin < 9) | isempty(AL) 
   disp('Mixing matrix from the preceeding layer unknown');
   AL = eye(size(Y,1));
end
if (nargin < 8) | isempty(restart_mc_on) | max(size(restart_mc_on) > 1)
   disp('Index od restarts in MC analysis unknown');
   restart_mc_on = 0;
end
if (nargin < 7) | isempty(NoAlts) | max(size(NoAlts) > 1)
   disp('Adjustable number of alternatings');
   NoAlts = [];
end
if (nargin < 6) | isempty(mc_on) | max(size(mc_on) > 1)
   disp('No Monte Carlo Analysis');
   mc_on = 0;
end
if (nargin < 5) | isempty(S) 
   disp('X_true not given');
end
if (nargin < 4) | isempty(A_true) 
   disp('A_true not given');
   index_fixed_A = 1;
else
   index_fixed_A = 0;  
end
if (nargin < 3) | isempty(Index_norm)
   '"Index_norm" must be specified'
   return
end
if (nargin < 2) | isempty(r)
   'Rank of factorization must be given'
   return
end
if isempty(Y) | isnan(Y)
   error('No data');
   return
end
% test for negative values in Y
if min(min(Y)) < 0
    disp('Some matrix entries are changed from negative to small positive');
    Y(Y< 0) = eps;
end
if min(sum(Y,2)) == 0
    disp('Not all entries in a row can be zero');
    return
end

Y = Y + eps;

[m,T]=size(Y);
niter_selected = 1000;     % maximum number of iterations for the selected sample (can be adjusted)
niter_sample = 10; % maximum number of iterations for each random sample
epsil_normA = 1E-8; % tolerance for alternating

if (alpha == 0) & (type_alg_A == 6)  
   type_alg_A = 5; 
end

if (type_alg_A == 8) & (size(A_true,1) ~= size(Y,1))
   disp('Multilayer technique cannot be used with A fixed');
   Distance_output = [];
   return
end

% Monte Carlo and alternatings adjustment
if mc_on & ~restart_mc_on
    max_restart = 0;
end
if ~isempty(NoAlts)
    niter_selected = NoAlts;
end

% Parameters for QP-NMF
rho = 1E-3;
eta = 1E-4;
epsil_A = 1E-6;

% Declaration for A and X
A=zeros(m,r);
Ap = A;
X=zeros(r,T);
Ainit = A;
Xinit = X;
Z = zeros(m,T);
KL_outer_temp = 0;
Z_outer_temp = 0;
nr = 0; restart_on = 0; norm_A = 10; nr_best = -1;
m_sx = 1:m; r_sx = 1:r; T_sx = 1:T;
s_dist = 0;

% Newton
HX = spalloc(r*T,r*T,T*r^2);
HA = spalloc(m*r,m*r,m*r^2);
E = ones(m,T);
I = eye(r);
Zx = zeros(m,T);
alpha_h_init = 1E-13;

while (nr <= max_restart)
         
   % Initialize random A and X
       if ~nr & (~mc_on | restart_mc_on)
          Ainit(m_sx',r_sx) = abs(repmat(.1*sin(2*pi*.1*m_sx'),1,r) + repmat(.1*cos(2*pi*.1*r_sx),m,1) + repmat(cos(2*pi*.471*m_sx'),1,r) + repmat(sin(2*pi*.471*r_sx),m,1));
          Ainit = Ainit/max(max(Ainit));
        
          Xinit(r_sx',T_sx) = abs(repmat(.1*sin(2*pi*.1*r_sx'),1,T) + repmat(.1*cos(2*pi*.1*T_sx),r,1) + repmat(cos(2*pi*.471*r_sx'),1,T) + repmat(sin(2*pi*.471*T_sx),r,1));
          Xinit = Xinit/max(max(Xinit));
       else
          Ainit=rand(m,r);
          Xinit=rand(r,T);
       end
           
        % Normalization of initial guess
        Ainit = Ainit*diag(1./sum(Ainit,1));
           
        if (nr == max_restart)&(max_restart > 0)
           A = A_best;
           X = X_best;
        else
           A = Ainit;
           X = Xinit;
        end % initial guess assignment
    
    Yx = zeros(m,T);
    n = 0; k = 0;
      
    
while ((k <= niter_sample)&(nr < max_restart)) | ((k <= niter_selected)&(nr == max_restart)&(norm_A > epsil_normA)& isempty(NoAlts)) | ((k <= niter_selected)&(nr == max_restart)& (NoAlts > 0)) 
 
k = k + 1;

    switch type_alg_X
        
        case 1 % ALS
                   
            X = max(1E6*eps,pinv(A'*A)*A'*Y);    
        
        case 2 % Regularized ALS
                    
            alpha_reg = alpha0*exp(-k/tau);
            if isnan(A)  disp('Matrix A is too much ill-conditioned. Try again.'); break; end
            if cond(A) > 1E6 alphaX = 1E-6; else alphaX = 0; end
            X = max(1E6*eps,pinv(A'*A + alpha_reg + alphaX*I)*A'*Y); %Updating of X    
                        
        case 3 % GPCG
                   
            X = gpcg_nmf(Y,A,X,no_iter,CostFun,alpha);
            
        case 4 % Kullback-Leibler (EMML)
            
             for t = 1:no_iter
                 X = (X.*(A'*(Y./(A*X + eps)))).^(1 + alphaS);
             end
             X = X + 100*eps;
                  
        case 5 % Frobenius (ISRA)
            
             for t = 1:no_iter
                 X = X.*((A'*Y)./(A'*A*X + eps));
             end
             X = X + 100*eps;
            
        case 6 % Newton applied to Frobenius
           
            hX = A'*A;
            GX = A'*Y - hX*X;
            HX = kron(speye(T),-hX); % Hessian
            hk = 0;
            alpha_h = alpha_h_init;
            while condest(HX) > 1E7
                  hk = hk + 1; 
                  alpha_h = 10*alpha_h;
                  HX = HX + alpha_h*speye(r*T);
            end
            [QX,RX] = qr(HX,GX(:));
            X(:) = X(:) - .9*RX\QX;
            X(X <= 0) = 100*eps;
            
        case 7 % Newton applied to KL

            Zx = A*X+1E5*eps;
            GX = A'*(E - Y./Zx);
            Zxx = (Y+100*eps)./Zx.^2;
            for t = 1:T
                HX(((t-1)*r+1):t*r,((t-1)*r+1):t*r) = A'*diag(Zxx(:,t))*A;
            end
            hk = 0;
            alpha_h = alpha_h_init;
            while condest(HX) > 1E7
                  hk = hk + 1;
                  alpha_h = 10*alpha_h;
                  HX = HX + alpha_h*speye(r*T);
            end
            [QX,RX] = qr(HX,GX(:));
            X(:) = X(:) + .9*RX\QX;
            X(X <= 0) = 100*eps;
            
        case 8 % Newton applied to dual KL (KL2)
        
            Zx = A*X+10*eps;
            Zxx = 1./Zx + eps;
            GX = A'*log(Zx./(Y + 10*eps));
            for t = 1:T
                HX(((t-1)*r+1):t*r,((t-1)*r+1):t*r) = A'*diag(Zxx(:,t))*A;
            end
            hk = 0;
            alpha_h = alpha_h_init;
            while condest(HX) > 1E7
                  hk = hk + 1;
                  alpha_h = 10*alpha_h;
                  HX = HX + alpha_h*speye(r*T);
            end
            [QX,RX] = qr(HX,GX(:));
            X(:) = X(:) - .9*RX\QX;
            X(X <= 0) = 100*eps;
            
        case 9 % QP with barrier function
            
            X = iptrnr(Y',A',no_iter,lambda,rho,eta,epsil_A);
            X = X'; 
            
        case 10 % Fixed X
            
            X = S + eps; 
            niter_selected = 1000;     % maximum number of iterations for the selected sample (can be adjusted)    
            
    end % switch for X
            
    switch type_alg_A
              
        
        case 1 % QP with barrier function
           
            Ap = A;
            A = iptrnr(Y,X,no_iter,lambda,rho,eta,epsil_A);
            A = A*diag(1./(sum(A,1)+eps));
        
        case 2 % GPCG
       
            Ap = A; 
            A = gpcg_nmf(Y',X',A',no_iter,CostFun,alpha);
            A = A';    
            
        case 3 % Newton applied to Frobenius
           
            Ap = A;
            hA = X*X';
            hA = hA + (1E-12 + 1E8*exp(-k))*eye(r);  % Levenberg-Marquardt regularization
            GA = X*Y' - hA*A';  % Gradient
            HA = kron(speye(m),-hA); % Hessian
       %    [QA,R] = qr(HA,GA(:)); % Q-less QR factorization
            cond_HA = condest(HA);
            if isinf(cond_HA)
               fprintf(1,'Hessian is singular in %d iteration(s). Restart is needed.\n',k) 
               break; 
            end
            A = A';
            A(:) = A(:) - .9*inv(HA)*GA(:);
          %  A(:) = A(:) - .9*R\QA;
            A(A <= 0) = 1E2*eps;
            A = A';
            A = A*diag(1./sum(A,1));
            
        case 4 % Newton applied to KL

            Ap = A;
            Zx = A*X+100*eps;
            Zxx = (Y+eps)./Zx.^2;
            for i = 1:m
                HA(((i-1)*r+1):i*r,((i-1)*r+1):i*r) = (X.*repmat(Zxx(i,:),r,1))*X'; % Hessian
            end
            HA = HA + (1E-12 + 1E15*exp(-2*k))*speye(m*r);
            GA = X*(1 - (Y+eps)./Zx)'; % Gradient
        %    [QA,R] = qr(HA,GA(:)); % Q-less QR factorization
            cond_HA = condest(HA);
            if isinf(cond_HA)
               fprintf(1,'Hessian is singular in %d iteration(s). Restart is needed.\n',k) 
               break; 
            end
            A = A';
            A(:) = A(:) - .9*inv(HA)*GA(:);
          %  A(:) = A(:) - .9*R\QA;
            A(A < 0) = 100*eps;
            A = A';
            A = A*diag(1./sum(A,1));
                   
        case 5 % Newton applied to dual KL (KL2)
        
            Zx = A*X+100*eps; Zxx = 1./Zx;
            GA = X*(log(Zx./(Y+eps)))'; % Gradient
            for i = 1:m
                HA(((i-1)*r+1):i*r,((i-1)*r+1):i*r)...
                = (X.*repmat(Zxx(i,:),r,1))*X';  % Hessian
            end    
            HA = HA + (1E-12 + 1E15*exp(-2*k))*speye(m*r);
           %    [QA,R] = qr(HA,GA(:)); % Q-less QR factorization
            cond_HA = condest(HA);
            if isinf(cond_HA)
               fprintf(1,'Hessian is singular in %d iteration(s). Restart is needed.\n',k) 
               break; 
            end
            A = A';
            A(:) = A(:) - .9*inv(HA)*GA(:);
          %  A(:) = A(:) - .9*R\QA;
            A(A < 0) = 100*eps;
            A = A';
            A = A*diag(1./sum(A,1));
     
        case 6 % Newton applied to alpha-divergence

            Ap = A;
            Zx = A*X+100*eps;
            Zxx = ((Y+eps).^alpha)./(Zx.^(alpha + 1));
            for i = 1:m
                HA(((i-1)*r+1):i*r,((i-1)*r+1):i*r) =...
                    (X.*repmat(Zxx(i,:),r,1))*X'; % Hessian
            end
            GA = (1/alpha)*X*(1 - ((Y+eps)./Zx).^alpha)'; % Gradient
            HA = HA + (1E-12 + 1E15*exp(-2*k))*speye(m*r);
       %    [QA,R] = qr(HA,GA(:)); % Q-less QR factorization
            cond_HA = condest(HA);
            if isinf(cond_HA)
               fprintf(1,'Hessian is singular in %d iteration(s). Restart is needed.\n',k) 
               break; 
            end
            A = A';
            A(:) = A(:) - .9*inv(HA)*GA(:);
         %  A(:) = A(:) - .9*R\QA;
            A(A < 0) = 100*eps;
            A = A';
            A = A*diag(1./sum(A,1));
            
        case 7 % Regularized ALS
            
            Ap = A;
            alpha_reg = alpha0*exp(-k/tau);
            A = max(1E6*eps, Y*X'*pinv(X*X' + alpha_reg));  
            A = A*diag(1./sum(A,1));
         
        case 8 % Fixed A
            
            niter_selected = 1000;     % maximum number of iterations for the selected sample (can be adjusted)
            A = A_true + eps;    
            A = A*diag(1./(sum(A,1) + eps));    
            
    end % switch for A
 

                if (nr == max_restart)&(mod(k,50)==0)& (~mc_on | restart_mc_on)
                    norm_A = norm(abs(A - Ap),'fro');
                    fprintf(1, 'Restart %d,  %d-th alternating step\n',nr_best+1,k);
                end
               
                if sum(Index_norm)
                   if (nr == max_restart) & (((k < 50) & (mod(k,5)==0)) | ((k>49) & ((mod(k,50)==0)))) 
                       
                       s_dist = s_dist + 1;
                       k_select(s_dist) = k;
                       Z = A*X + eps;
                       Z = diag(1./sqrt(var(Z')))*Z;
                      
                        dist_Fro(s_dist) = norm(Y - Z,'fro'); 
                        dist_KL(s_dist) = sum(sum(Y.*log(Y./Z + eps) - Y + Z)); 
                        dist_KL2(s_dist) = sum(sum(Z.*log(Z./Y + eps) + Y - Z)); 
                        dist_Pearson(s_dist) = sum(sum( ((Y - Z).^2)./Z ));
                        dist_Hellinger(s_dist) = sum(sum( (sqrt(Z) - sqrt(Y)).^2 )); 
                        dist_JS_rel(s_dist) = sum(sum(2*Y.*log(2*Y./(Y + Z) + eps) + Z - Y));  
                        dist_JS_rel2(s_dist) = sum(sum(2*Z.*log(2*Z./(Y + Z) + eps) - Z + Y));  
                        Zy = Y + Z; 
                        dist_JS(s_dist) = sum(sum(Y.*log(2*Y./Zy + eps) + Z.*log(2*Z./Zy + eps) ));  
                        dist_AG_rel(s_dist) = sum(sum(Zy.*log(.5*Zy./Y + eps) + Y - Z));  
                        dist_AG(s_dist) = sum(sum(.5*Zy.*log(.5*Zy./sqrt(Y.*Z) + eps)));  
                        dist_J(s_dist) = sum(sum( .5*(Y - Z).*log(Y./Z + eps) ));  
                        dist_Chi(s_dist) = sum(sum( ((Y + Z).*(Y - Z).^2)./(Y.*Z) ));  
                        dist_Tria(s_dist) = sum(sum( ((Y - Z).^2)./(Y + Z) ));  
                    end % if multiple
                end % if sum
                
end % while (k)

% Outer KL divergence
Z = AL*A*X; 
Z_outer = norm(Z,'fro') + eps;
KL_outer = sum(sum(Y_true.*log((Y_true + eps)./(Z + eps)) - Y_true + Z))/Z_outer;
         
           if (nr == 0) | (KL_outer < KL_outer_temp)
              A_best = A; X_best = X; KL_outer_temp = KL_outer; nr_best = nr;
           end % multi-conditions
                
   nr = nr + 1;
   
   if nr <=max_restart
      fprintf(1, 'Restart %d, Kullback-Leibler divergence = %e\n',	nr, KL_outer);
   end
   
end % while (restarts)

% One-Variance scaling
X(X <= 0) = eps;

Distance_output = cell(length(s_dist),1);
Distance_output(1) = {[]};
Distance_output(2) = {[]};
Distance_output(3) = {[]};
Distance_output(4) = {[]};
Distance_output(5) = {[]};
Distance_output(6) = {[]};
Distance_output(7) = {[]};
Distance_output(8) = {[]};
Distance_output(9) = {[]};
Distance_output(10) = {[]};
Distance_output(11) = {[]};
Distance_output(12) = {[]};
Distance_output(13) = {[]};
Distance_output(14) = {[]};

if sum(Index_norm)
   Distance_output(1) = {k_select}; 
   Distance_output(2) = {dist_Fro};
   Distance_output(3) = {dist_KL};
   Distance_output(4) = {dist_KL2};
   Distance_output(5) = {dist_Pearson};
   Distance_output(6) = {dist_Hellinger};
   Distance_output(7) = {dist_JS_rel};
   Distance_output(8) = {dist_JS_rel2};
   Distance_output(9) = {dist_JS};
   Distance_output(10) = {dist_AG_rel};
   Distance_output(11) = {dist_AG};
   Distance_output(12) = {dist_J};
   Distance_output(13) = {dist_Chi};
   Distance_output(14) = {dist_Tria};
end



