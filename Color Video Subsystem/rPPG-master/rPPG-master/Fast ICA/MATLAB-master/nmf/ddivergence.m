function d = ddivergence(A,B)
% d = ddivergence(A,B);
dm = A.*log (A./B) - A + B;
d = sum(dm(:));
% d = sum(sum(A .* log (A./B))); %KLdiv
end