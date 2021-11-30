function [finalSignal]=Coherence_Power_HRanalysis_5(signalProcessing,finalSignal)
%% Returns HR Signal (freq*60) based on best ICA component based either on Maximum Power of PSD OR maximum coherence. These result should be very similar.
finalSignal.maxPower        = [];
finalSignal.maxCoherence    = [];
tempMaxPowerIdx             = [];
tempMaxCoherenceIdx         = [];
for co = 1:signalProcessing.ica.nComps
    [finalSignal.maxPower(co),tempMaxPowerIdx(co)] = max(finalSignal.powerVal(signalProcessing.fft.fRange2,co));
    [finalSignal.maxCoherence(co),tempMaxCoherenceIdx(co)] = max(finalSignal.coherenceVal(signalProcessing.fft.fRange2,co));
end
[~,tempMaxPowerCompIdx] = max(finalSignal.maxPower);
[~,tempMaxCoherenceCompIdx] = max(finalSignal.maxCoherence);

finalSignal.HRfreqIdx_powerBased    = tempMaxPowerIdx(tempMaxPowerCompIdx);
finalSignal.HR_powerBased           = signalProcessing.fft.freq(signalProcessing.fft.fRange2(tempMaxPowerIdx(tempMaxPowerCompIdx)))*60;
finalSignal.HR_powerBased_PerComp   = signalProcessing.fft.freq(signalProcessing.fft.fRange2(tempMaxPowerIdx))*60;
finalSignal.HRBestCompIdx_powerBased    = tempMaxPowerCompIdx;

finalSignal.HRfreqIdx_coherenceBased    = tempMaxCoherenceIdx(tempMaxCoherenceCompIdx);
finalSignal.HR_coherenceBased           = signalProcessing.fft.freq(signalProcessing.fft.fRange2(tempMaxCoherenceIdx(tempMaxCoherenceCompIdx)))*60;
finalSignal.HR_PerComp_coherenceBased   = signalProcessing.fft.freq(signalProcessing.fft.fRange2(tempMaxCoherenceIdx))*60;
finalSignal.HRBestCompIdx_coherenceBased    = tempMaxCoherenceCompIdx;


%% adding frequency to finalSignal from signalProcessing for simplicity
finalSignal.freq=signalProcessing.fft.freq; % full frequencies
finalSignal.fRange2=signalProcessing.fft.fRange2; % concat IDx

end