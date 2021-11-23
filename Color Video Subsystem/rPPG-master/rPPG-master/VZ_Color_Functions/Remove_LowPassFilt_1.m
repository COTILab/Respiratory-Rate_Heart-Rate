function filt1_struct=Remove_LowPassFilt_1(signalProcessing,interp_struct)
% 1. signalProcessing: Struct with several signal processing fields. The
% definition of this struct is UNMODIFIED from the original Runme.mat file
% from github

% 2. interp_struct; our interpolated data struct. input to filter
%%%%%%%
t_start_2=tic;
pixelVal_filt = interp_struct.resampledYData;
for c = 1:3
    if signalProcessing.highPassPixelFilter.active
        pixFilter = filtfilt(signalProcessing.highPassPixelFilter.NthOrder,signalProcessing.highPassPixelFilter.cutOffFreq,interp_struct.resampledYData(:,c)); % low pass filter
        pixelVal_filt(:,c) = interp_struct.resampledYData(:,c)-pixFilter; % removing low pass filtered data. basically removes minor moton artifacts
    else
        pixelVal_filt(:,c) = interp_struct.resampledYData(:,c); % if you dont want to filter, just take the raw input
    end
end
%% adding to struct
filt1_struct.pixelVal_filt=pixelVal_filt; % Filtered data

filt1_struct.resampledXData=interp_struct.resampledXData; % keeping time stamps

filt1_struct.t_filt=toc(t_start_2); % time this step takes






end