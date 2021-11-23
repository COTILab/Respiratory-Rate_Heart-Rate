function cmax = computeCorrelationInResiduals(data, model)
% cmax = computeCorrelationInResiduals(data, model)
%
% Computes maximum correlation in residuals (standartised): 
% residuals: (data-model)/sqrt(model)

resid = (data - model)./model;
c = corrcoef(resid');
cmax = max(c(c<1)); % c<1 restrict to off-diagonal elements
