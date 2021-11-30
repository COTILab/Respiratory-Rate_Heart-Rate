function finalSignal =LowPass_PSDCoherence_4(signalProcessing,finalSignal)
% Low pass filter and computing coherence for EVERY ICA component
 finalSignal.oldPowerValPREFILTER=finalSignal.powerVal; % adding by RR for debugging

finalSignal.coherenceVal = [];
for co = 1:signalProcessing.ica.nComps
    if signalProcessing.lowPassPSDFilter.active
        finalSignal.powerVal(:,co) = filtfilt(signalProcessing.lowPassPSDFilter.NthOrder,signalProcessing.lowPassPSDFilter.cutOffFreq,finalSignal.powerVal(:,co));
    end

    finalSignal.coherenceVal(:,co) = finalSignal.powerVal(:,co)./sqrt(sum(finalSignal.powerVal(signalProcessing.fft.fRange2,co).^2));
%     finalSignal.coherenceVal(:,co) = finalSignal.powerVal(:,co)./sqrt(sum(finalSignal.powerVal(:,co).^2));

end
end