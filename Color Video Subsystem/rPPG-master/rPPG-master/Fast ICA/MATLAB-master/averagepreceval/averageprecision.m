function [AP,TP,FN,FP,prec,rec,mdAll,levh]=averageprecision(coord_est,coord_true,radiustrue,intens)
% Evaluates average precision for set of true and estimated points. See S407_report for details. 
% References: Everingham, M., Gool, L., Williams, C.K.I., Winn, J. & Zisserman, A. The Pascal Visual Object Classes (VOC) Challenge. International Journal of Computer Vision 88, 303-338 (2009).
%
% [AP,TP,FN,FP,prec,rec,mdAll]=averageprecision(coord_est,coord_true,radiustrue,intens)
% input:  coord_est - Nx2 matrix of estimated coordinates
%         coord_true- Nx2 matrix of true coordinates
%         radiustrue - limit on distance between true and estimated coordinates. For smaller distance the estimated point is considered as a true positive (can be set to sigma/2, where sigma is the std of the gaussian approximation of hte PSF.)
%         intens - Nx1 vector of intensity of the estimated source
%         
% output: AP - average precision
%         TP - true positives
%         FN - false negatives
%         FP - false poitives
%         prec - precision
%         rec - recall 
%         mdAll - localisation precision at the lowest confidence level

% levn = 100; % number of confidence levels for AP (see S407_report.pdf)

levh=sort(unique(sqrt(double(intens))));
levn=length(levh); % number of different intensities

nT=size(coord_true,1);
nE=size(coord_est,1);
minh=min(levh);
maxh=max(levh);
% levh=minh+(maxh-minh)/(levn-1)*[0:levn-1];

TP=zeros(levn,1);
FP=nE*ones(levn,1);
FN=nT*ones(levn,1);
T = coord_true;
mdAll=mindistsep(T,coord_est);
for ii=1:levn
    index = sqrt(intens)>=levh(ii); % above the limit brightness   
    E = coord_est(index,:);
    [md,mT,mE]=mindistsep(T,E); % mT and mE are indeces of points connected by a distance md.
    TP(ii) = sum(md<=radiustrue); %true positives
    setDiffE=setdiff(1:size(E,1),mE); % These estimated points have not been assighned to any true point.
    setDiffT=setdiff(1:size(T,1),mT); % These true points have not been assighned to any estimated point.
    FP(ii) = numel(setDiffE)+sum(md>radiustrue); %False positives: points futher from true then md, and estimated pints without any assigned true point
    FN(ii) = numel(setDiffT)+sum(md>radiustrue); %False negatives: points futher from true then md, and true poitions without any assigned esitmated point
end

prec = TP./(TP+FP);
rec = TP./(TP+FN);

precinterpol = zeros(11,1);
for ii=0:10;
    recind=rec>=(.1*ii);
    maxprec = max(prec(recind));
    if ~isempty(maxprec)
        precinterpol(ii+1)=maxprec;
    end
end

AP=1/11*sum(precinterpol);