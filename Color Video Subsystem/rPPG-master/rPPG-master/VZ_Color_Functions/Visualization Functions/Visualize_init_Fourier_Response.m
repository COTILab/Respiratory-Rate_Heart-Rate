function Visualize_init_Fourier_Response(signalProcessing,finalSignal)
% plot fourier response of each ICA component and the reconstructed time
% domain
%% First Separate plots
figure;
subplot(2,2,1)
plot(signalProcessing.fft.HRRange,finalSignal.powerVal(signalProcessing.fft.fRange2,1));
[max_val_1,max_I_1]=max(finalSignal.powerVal(signalProcessing.fft.fRange2,1));
hold on
plot(signalProcessing.fft.HRRange(max_I_1),max_val_1,'rx','MarkerSize',12)
xlabel("Heart Beat (Bpm)")
ylabel("Magnitude")
title("Component 1--Power")

subplot(2,2,2)
plot(signalProcessing.fft.HRRange,finalSignal.powerVal(signalProcessing.fft.fRange2,2));
[max_val_2,max_I_2]=max(finalSignal.powerVal(signalProcessing.fft.fRange2,2));
hold on
plot(signalProcessing.fft.HRRange(max_I_2),max_val_2,'rx','MarkerSize',12)

xlabel("Heart Beat (Bpm)")
ylabel("Magnitude")
title("Component 2--Power")

subplot(2,2,3)
plot(signalProcessing.fft.HRRange,finalSignal.powerVal(signalProcessing.fft.fRange2,3));
[max_val_3,max_I_3]=max(finalSignal.powerVal(signalProcessing.fft.fRange2,3));
hold on
plot(signalProcessing.fft.HRRange(max_I_3),max_val_3,'rx','MarkerSize',12)
xlabel("Heart Beat (Bpm)")
ylabel("Magnitude")
title("Component 3--Power")
%% Combined-- Showing overlapped plots-- Power and Coherence based
figure();
subplot(2,2,1);
plot(signalProcessing.fft.HRRange,finalSignal.powerVal(signalProcessing.fft.fRange2,:));
hold on
line([repmat(finalSignal.HR_powerBased,1,2)],[0 max(finalSignal.powerVal(signalProcessing.fft.fRange2,finalSignal.HRBestCompIdx_powerBased))],'Color','k','LineStyle',':','LineWidth',2)
xlabel('HR')
ylabel('Power')

subplot(2,2,2)
plot(signalProcessing.fft.HRRange,finalSignal.coherenceVal(signalProcessing.fft.fRange2,:));
hold on
line([repmat(finalSignal.HR_coherenceBased,1,2)],[0 max(finalSignal.coherenceVal(signalProcessing.fft.fRange2,finalSignal.HRBestCompIdx_coherenceBased))],'Color','k','LineStyle',':','LineWidth',2)
xlabel('HR')
ylabel('Coherence')
legend('Component 1','Component 2','Component 3')

subplot(2,2,4);
plot(finalSignal.resampledXData,finalSignal.comp(finalSignal.HRBestCompIdx_coherenceBased,:),'k')
title('Best component - coherence based')
ylabel('Pixel val')
xlabel('Time [s]')








end