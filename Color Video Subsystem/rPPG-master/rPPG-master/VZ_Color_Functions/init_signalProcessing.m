function signalProcessing=init_signalProcessing()
% initialized signalProcessing struct
signalProcessing = struct();
signalProcessing.samplingRate               = 60;       % [frames per second] sampling rate: temporal resolution of pixel value signal will increase with interpolation to X Hz
signalProcessing.interpMethod               = 'pchip';  % rPPG signal is always interpolated to a frequency of the sampling rate
signalProcessing.FOI                        = [45 165]; % range: [min max] frequency of interest of heart rate in Beats per minute (BPM)
signalProcessing.highPassPixelFilter.active = 1;        % [0 1]; 1 = apply low pass filter to pixel values ... to remove artifacts by movement or illumination
signalProcessing.highPassPixelFilter.params = [6 (signalProcessing.FOI(1)/60)/(signalProcessing.samplingRate/2)];     % [int 0.01-0.10] butterworth parameters --> [6 0.04] is ideal for frame rate of 30

signalProcessing.lowPassPSDFilter.active    = 1;        % [0 1]; 1 = apply low pass filter to power density spectrum to remove spurious peaks due to noise
signalProcessing.lowPassPSDFilter.params    = [8 0.2];  % [int 0.01-0.10] butterworth parameters [Xth_order cutoff_freq]
signalProcessing.lowPassHRTimeFilter.active = 1;        % [0 1]; 1 = apply low pass filter to heart rate over time to remove spurious changes in HR due to noise
signalProcessing.lowPassHRTimeFilter.params = [8 0.03]; % [int 0.01-0.10] butterworth parameters [Xth_order cutoff_freq]
            
[signalProcessing.highPassPixelFilter.NthOrder,signalProcessing.highPassPixelFilter.cutOffFreq] = butter(signalProcessing.highPassPixelFilter.params(1),signalProcessing.highPassPixelFilter.params(2));
[signalProcessing.lowPassPSDFilter.NthOrder,signalProcessing.lowPassPSDFilter.cutOffFreq]       = butter(signalProcessing.lowPassPSDFilter.params(1),signalProcessing.lowPassPSDFilter.params(2));
[signalProcessing.lowPassHRTimeFilter.NthOrder,signalProcessing.lowPassHRTimeFilter.cutOffFreq] = butter(signalProcessing.lowPassHRTimeFilter.params(1),signalProcessing.lowPassHRTimeFilter.params(2));

signalProcessing.ica.nComps                  = 3;        %
signalProcessing.ica.nIte                    = 2000;     %
signalProcessing.ica.stab                    = 'on';     %
signalProcessing.ica.verbose                 = 'off';    %






end