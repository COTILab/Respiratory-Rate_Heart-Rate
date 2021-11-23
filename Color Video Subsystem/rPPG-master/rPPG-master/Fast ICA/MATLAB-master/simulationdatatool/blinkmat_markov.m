function blinkmat = blinkmat_markov(N,Nt, intensity_vec, probtrans)
% blinkmat = blinkmat_markov(N,Nt, intensity_vec, probtrans)
% Generates NxNt blinking matrix with maximum inteinisty (intensity_vec)
% and probability transition probtrans
% 
% Example:
% bm=blinkmat_markov(3,500,ones(3,1),.5);

intensity_mat = repmat(intensity_vec, 1,Nt);
changemat = rand(N,Nt)<probtrans;
statemat = mod(cumsum(changemat,2),2);
initvec = rand(N,1)>0.5; %initial state of the blinkmat
ivt = ~(initvec == statemat(:,1));
statematinit = mod(statemat+repmat(ivt,1,Nt),2);
blinkmat = statematinit .* intensity_mat; %different intensities...
