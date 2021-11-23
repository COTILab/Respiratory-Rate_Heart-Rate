function finalSignal=fastICA_analysis_2(signalProcessing,filt1_struct)

%%1 . signalProcessing: Struct with several signal processing fields. The
% definition of this struct is UNMODIFIED from the original Runme.mat file
% from github

% 2. filt1_struct; our filtered data struct. input to filter
t_start_2=tic;
finalSignal = struct();

finalSignal.comp                = fastica(filt1_struct.pixelVal_filt','numOfIC',signalProcessing.ica.nComps,'maxNumIterations',signalProcessing.ica.nIte,'stabilization',signalProcessing.ica.stab,'verbose',signalProcessing.ica.verbose);

%% Add to struct
%finalSignal.ICA_comp=
finalSignal.resampledXData=filt1_struct.resampledXData;
finalSignal.t_ICA_end=toc(t_start_2);
