function buffer_visualization (signalProcessing,finalSignal,out_struct)

nrows=2;
ncols=2;

subplot(nrows,ncols,1);
plot(signalProcessing.fft.HRRange,finalSignal.powerVal(signalProcessing.fft.fRange2,:));
%hold on
line([repmat(finalSignal.HR_powerBased,1,2)],[0 max(finalSignal.powerVal(signalProcessing.fft.fRange2,finalSignal.HRBestCompIdx_powerBased))],'Color','k','LineStyle',':','LineWidth',2)
xlabel('HR')
ylabel('Power')

subplot(nrows,ncols,2)
plot(signalProcessing.fft.HRRange,finalSignal.coherenceVal(signalProcessing.fft.fRange2,:));%
%hold on
line([repmat(finalSignal.HR_coherenceBased,1,2)],[0 max(finalSignal.coherenceVal(signalProcessing.fft.fRange2,finalSignal.HRBestCompIdx_coherenceBased))],'Color','k','LineStyle',':','LineWidth',2)
xlabel('HR')
ylabel('Coherence')
legend('Component 1','Component 2','Component 3')

%% Scattering results that we care about more..
subplot(nrows,ncols,4)
scatter( out_struct.times(end), out_struct.HR_coh(end));
hold on
title("Coherence Heart Rate vs time")
ylabel("HR (bpm)")
xlabel("Time(seconds)")

subplot(nrows,ncols,3)
scatter( out_struct.times(end), out_struct.HR_pow(end));
hold on
title("Heart Rate- power spectrum vs time")
ylabel("HR (bpm)")
xlabel("Time(seconds)")

drawnow

end