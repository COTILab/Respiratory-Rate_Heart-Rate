function interp_struct=Spline_3_channel(signalProcessing,image_struct,pixelValPerFrame)
%% Returns interpolated data and relevant fields used later
% 1. signalProcessing: Struct with several signal processing fields. The
% definition of this struct is UNMODIFIED from the original Runme.mat file
% from github

% 2. image_struct; our raw image struct. used to extract time stamps mainly

% 3. pixelValPerFrame: number of frames x 3 matrix: Averaged of selected
% pixels per frame. already computed prior

t_start_2=tic;

startIdx        = find(isfinite(pixelValPerFrame(:,1)),1,'first');
endIdx          = find(isfinite(pixelValPerFrame(:,1)),1,'last');

xdata           = image_struct.ts(startIdx:endIdx)-image_struct.ts(startIdx);%vidInfo.tStamp(startIdx:endIdx)-vidInfo.tStamp(startIdx); % time stamps
resampledXdata  = linspace(xdata(1),xdata(end),ceil(signalProcessing.samplingRate*(xdata(end)-xdata(1)))); % scaling based on sample rate.. basically splining video to set frame rate
resampledYdata = NaN(length(resampledXdata),3);

for c = 1:3     %% Splines data to fit expected sampling rate for each RGB Component 
    ydata = pixelValPerFrame(startIdx:endIdx,c);
    vect = isfinite(ydata);                
    resampledYdata(:,c) = interp1(xdata(vect),ydata(vect),resampledXdata,signalProcessing.interpMethod);
end
%% Adding to final struct
interp_struct.resampledYData=resampledYdata; % Resampled Y Data. Splined based on specified frame rate
interp_struct.resampledXData=resampledXdata; % NEW TIME STAMPS
interp_struct.orig_xdata=xdata; % original time stamps
interp_struct.orig_ydata=pixelValPerFrame; % original unsplined data
interp_struct.t_end=toc(t_start_2); % time taken to interpolate



end