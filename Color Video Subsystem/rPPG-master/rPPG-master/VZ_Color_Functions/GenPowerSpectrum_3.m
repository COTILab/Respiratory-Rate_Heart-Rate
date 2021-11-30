function [signalProcessing,finalSignal]=GenPowerSpectrum_3(signalProcessing,finalSignal)
%% Written on 23NOV21 -- Updated signalProcessing struct to compute PSD( same as original script but we modularize it)
%% Additionally compute Power Spectral Density for further analysis on EVERY ICA component

signalProcessing.fft.L                  = signalProcessing.samplingRate*length(finalSignal.resampledXData); %% Number of frequencies determined on length of data
signalProcessing.fft.NFFT               = 2^nextpow2(signalProcessing.fft.L); % Next power of 2 from length of y
signalProcessing.fft.freq               = signalProcessing.samplingRate/signalProcessing.fft.NFFT*(0:signalProcessing.fft.NFFT-1);
signalProcessing.fft.freqInterestRange  = signalProcessing.FOI/60;
signalProcessing.fft.fRange2            = find(signalProcessing.fft.freq>signalProcessing.fft.freqInterestRange(1) & signalProcessing.fft.freq<signalProcessing.fft.freqInterestRange(2));
signalProcessing.fft.HRRange            = 60*signalProcessing.fft.freq(signalProcessing.fft.fRange2);

finalSignal.powerVal     = [];
for co = 1:signalProcessing.ica.nComps

    Y                 = fft(finalSignal.comp(co,:),signalProcessing.fft.NFFT); % calculate frequency spectrum
    finalSignal.powerVal(:,co)    = Y.*conj(Y)/signalProcessing.fft.NFFT;

end