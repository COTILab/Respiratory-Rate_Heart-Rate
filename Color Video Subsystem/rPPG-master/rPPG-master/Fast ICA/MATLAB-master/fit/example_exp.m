%this is in separate m file example_exp.m
function y = example_exp(x,p);
y = p(1)*exp(x-p(2))+p(3);