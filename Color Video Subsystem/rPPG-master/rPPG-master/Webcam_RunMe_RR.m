%% Modified by RR 11-15-2021
close all
clear all
clc
imaqreset
%% Uses webcam to acquire images with a circular buffer. Very similar type of algorithm( PCA) using ambient 
addpath(genpath('./Fast ICA'));
addpath(genpath('../../../NIR Video Subsystem')); %addpath(genpath('../../../Matlab+Python Acquisition')); % Access to all the functions we wrote for the IR based system.
addpath(genpath('./VZ_Color_Functions'))
%% Git hub repositories used
% 1. https://github.com/marnixnaber/rPPG
% Dependencies: https://github.com/aludnam/MATLAB/tree/master/FastICA_25
%% READ ME
buffer_length=150; % init buffer length in frames
buffer_cycles=10; % 0 if we want an inf loop 
dead_frames=20; % each time we initialize webcam, we throw out the first number of frames specified by this variable. Higher value=slower response
refresh_frames=50; % how many new frames do we take before we reanalyze

%% adding to buffer_struct for later
buffer_struct.buffer_length=buffer_length;
buffer_struct.buffer_cycles=buffer_cycles;
buffer_struct.refresh_frames=refresh_frames;


%num_frames=100;
% vid = videoinput('winvideo', 1, 'RGB24_320x240');
% triggerconfig(vid, 'manual');
% src = getselectedsource(vid);
% vid.FramesPerTrigger = num_frames;
% 
% % changing settings accordingly for internal cam
% %available_res=get(cam,'AvailableResolutions');
% %set(cam,'Resolution',available_res{3})
% %set(cam,'ExposureMode','manual') % manual Exposure
% %set(cam,'Exposure',-3) % max exposure for internal camera
% %set(cam,'WhiteBalanceMode','manual')
% %set(cam,'WhiteBalance',4600)
% 
% start(vid)
% trigger(vid)
% [images,ts]=(getdata(vid,num_frames));
% average_frame_rate=1/mean(diff(ts));
% This script performs a remote photoplethysmography (rPPG) analysis on
% videos with algorithms as described in the following publication:
% 
% van der Kooij & Naber (2018). Standardized procedures for the testing and 
% reporting of remote heart rate imaging. Behavior Research Methods
%
% Below you can vary the parameters for the signal processing steps (e.g.
% frequency filtering).
% 
% In the "extractFaceFromVideo.m" file you will find more parameters that
% can be adjusted (e.g., sensitivity to detect faces, number of points to
% track the face, and method to detect skin pixels)


% --------LICENSE & ACKNOWLEDGMENT-----------
% 
% Copyright ? 2017 Marnix Naber, The Netherlands
% 
% This program is distributed under the terms of the GNU General Public
% License (see gpl.txt)
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
% 
% When you have used this script for scientific purposes, please acknowledge 
% and cite the following reference: 
% 
% van der Kooij & Naber (2018). Standardized procedures for the testing and 
% reporting of remote heart rate imaging. Behavior Research Methods
%
%
%
% -----------------CONTACT-------------------
% 
% For questions about, remarks on, or problems with the code, 
% please contact: marnixnaber@gmail.com
%
% This script was tested in Matlab version 2014b. In case this script
% does not run because of an error reporting a missing function, then
% please check your matlab version and installed toolboxes. To run this
% script succesfully, the image processing toolbox and computer vision
% system toolbox should be installed.


%% Flags 
visualization_flag=0; % Visualize EVERY STEP for us 
%% set parameters

%% scaling factor,block size, point tracker, Face detector etc initialization
Refresh_ROI_Frames=1;% How many frames do we want to recalculate the ROI
sf=1.05; % Lower =Higher chance of catching face BUT more computationally expensive+ higher false positives
num_pyr=4; % higher= better tracking but slower
bl_sz=51; % MUST BE ODD NUMBER
KLT_conf=0.8; % what value we drop below before we use cascade detector, Higher value=more accurate but slower
%% initializing trackers-- We have a chest KLT tracker if WE WANT to use it but it may not be necessary
pointTracker_Face = vision.PointTracker('BlockSize',[bl_sz bl_sz],'NumPyramidLevels',num_pyr);
pointTracker_Chest=vision.PointTracker('BlockSize',[bl_sz bl_sz],'NumPyramidLevels',num_pyr);
faceDetector = vision.CascadeObjectDetector('ScaleFactor',sf(1)); % initializing

%% adding to buffer struct
buffer_struct.pointTracker_Face=pointTracker_Face;
buffer_struct.pointTracker_Chest=pointTracker_Chest;
buffer_struct.faceDetector=faceDetector;
buffer_struct.Refresh_ROI_Frames=Refresh_ROI_Frames;
buffer_struct.KLT_conf=KLT_conf;
buffer_struct.dead_frames=dead_frames;
%% Settings structure for this method

signalProcessing=init_signalProcessing();
%% Find Face using OUR FUNCTION -RR
t_start=tic;
disp("Acquisition started")
image_struct=Take_Internal_Webcam_Images(buffer_length,dead_frames); % take images
t_take_img=toc(t_start);
[DetectedFaceStruct,~,detail_struct]=GetFaceandChestROI(image_struct,faceDetector,pointTracker_Face,pointTracker_Chest,KLT_conf,Refresh_ROI_Frames);
t_find_face=toc(t_start);
%% Have to make it so DetectedFaceStruct has same relevant fields in struct so we can use methods such as K-Means
% Note Only SOME of these are used in kmeans. I include all parameters so
% we can use any of the methods if we desire in the future
% Fill in Struct so it has same fields and parameters

%% FOR NOW K-Means by default
DetectedFaceStruct=Fill_in_Face_Struct(DetectedFaceStruct);

% DetectedFaceStruct.nFaceSectors=12; 
% DetectedFaceStruct.method=2;
% DetectedFaceStruct.nColorClusters=4; 
% DetectedFaceStruct.calcFrameRate=0;
% DetectedFaceStruct.fracPixelsPresent = 0.8;      % [0-1]; fraction of colored pixels within a face grid sector that needs to be detected as skin color
% x = faceDetection.bbox(1, 1); 
% y = faceDetection.bbox(1, 2); 
% w = faceDetection.bbox(1, 3); 
% h = faceDetection.bbox(1, 4);
% faceDetection.bboxPolygon = [x, y, x+w, y, x+w, y+h, x, y+h];
% %% NOTE THESE ARE INCOMPLETE. HAVE TO LOOK TO SEE WHAT THESE MEAN
% DetectedFaceStruct.firstTimeDetected=1;
% DetectedFaceStruct.nTimesDetected=1;
% %% Needed for k means
% DetectedFaceStruct.f=1;
%% %% % % 
 [Masked_Images,pixelValPerFrame,t_mask]=K_Means_Masking(image_struct,DetectedFaceStruct);
 t_end_masking=toc(t_start);
if visualization_flag==1 % visualize face
Visualize_Face_Data(image_struct,DetectedFaceStruct,Masked_Images);     %% Raw Face 
    
end



%videoFileName                               = 'rPPG_video.mp4';
%% Use the original settings for filtering and analyzing as a start

% signalProcessing = struct();
% signalProcessing.samplingRate               = 60;       % [frames per second] sampling rate: temporal resolution of pixel value signal will increase with interpolation to X Hz
% signalProcessing.interpMethod               = 'pchip';  % rPPG signal is always interpolated to a frequency of the sampling rate
% signalProcessing.FOI                        = [45 165]; % range: [min max] frequency of interest of heart rate in Beats per minute (BPM)
% signalProcessing.highPassPixelFilter.active = 1;        % [0 1]; 1 = apply low pass filter to pixel values ... to remove artifacts by movement or illumination
% signalProcessing.highPassPixelFilter.params = [6 (signalProcessing.FOI(1)/60)/(signalProcessing.samplingRate/2)];     % [int 0.01-0.10] butterworth parameters --> [6 0.04] is ideal for frame rate of 30
% 
% signalProcessing.lowPassPSDFilter.active    = 1;        % [0 1]; 1 = apply low pass filter to power density spectrum to remove spurious peaks due to noise
% signalProcessing.lowPassPSDFilter.params    = [8 0.2];  % [int 0.01-0.10] butterworth parameters [Xth_order cutoff_freq]
% signalProcessing.lowPassHRTimeFilter.active = 1;        % [0 1]; 1 = apply low pass filter to heart rate over time to remove spurious changes in HR due to noise
% signalProcessing.lowPassHRTimeFilter.params = [8 0.03]; % [int 0.01-0.10] butterworth parameters [Xth_order cutoff_freq]
%             
% [signalProcessing.highPassPixelFilter.NthOrder,signalProcessing.highPassPixelFilter.cutOffFreq] = butter(signalProcessing.highPassPixelFilter.params(1),signalProcessing.highPassPixelFilter.params(2));
% [signalProcessing.lowPassPSDFilter.NthOrder,signalProcessing.lowPassPSDFilter.cutOffFreq]       = butter(signalProcessing.lowPassPSDFilter.params(1),signalProcessing.lowPassPSDFilter.params(2));
% [signalProcessing.lowPassHRTimeFilter.NthOrder,signalProcessing.lowPassHRTimeFilter.cutOffFreq] = butter(signalProcessing.lowPassHRTimeFilter.params(1),signalProcessing.lowPassHRTimeFilter.params(2));
% 
% signalProcessing.ica.nComps                  = 3;        %
% signalProcessing.ica.nIte                    = 2000;     %
% signalProcessing.ica.stab                    = 'on';     %
% signalProcessing.ica.verbose                 = 'off';    %

%%
%miguel=tic;
%pixelValPerFrame,faceMap,vidInfo,faceDetection,faceTracking] = extractFaceFromVideo(videoFileName,[0 2], 0);disp("NO DISPLAYING")
%[pixelValPerFrame,faceMap,vidInfo,faceDetection,faceTracking] = extractFaceFromVideo(videoFileName,'all', 1);


%% cutoff beginning and end if missing values, and fill missing values, and resample 
% interpolating raw data

interp_struct=Spline_3_channel(signalProcessing,image_struct,pixelValPerFrame); % Functionalized by RR
%% OLD CODE FROM ORIGINAL SCRIPT
% startIdx        = find(isfinite(pixelValPerFrame(:,1)),1,'first');
% endIdx          = find(isfinite(pixelValPerFrame(:,1)),1,'last');
% 
% xdata           = image_struct.ts(startIdx:endIdx)-image_struct.ts(startIdx);%vidInfo.tStamp(startIdx:endIdx)-vidInfo.tStamp(startIdx); % time stamps
% resampledXdata  = linspace(xdata(1),xdata(end),ceil(signalProcessing.samplingRate*(xdata(end)-xdata(1)))); % scaling based on sample rate.. basically splining video to set frame rate
% resampledYdata = NaN(length(resampledXdata),3);
% 
% for c = 1:3     %% Splines data to fit expected sampling rate for each RGB Component 
%     ydata = pixelValPerFrame(startIdx:endIdx,c);
%     vect = isfinite(ydata);                
%     resampledYdata(:,c) = interp1(xdata(vect),ydata(vect),resampledXdata,signalProcessing.interpMethod);
% end

%% Filter out low frequency changes
filt1_struct=Remove_LowPassFilt_1(signalProcessing,interp_struct);

%% OLD ORIGNAL CODE 

% pixelVal_filt = resampledYdata;
% for c = 1:3
%     if signalProcessing.highPassPixelFilter.active
%         pixFilter = filtfilt(signalProcessing.highPassPixelFilter.NthOrder,signalProcessing.highPassPixelFilter.cutOffFreq,resampledYdata(:,c)); % low pass filter
%         pixelVal_filt(:,c) = resampledYdata(:,c)-pixFilter; % removing low pass filtered data. basically removes minor moton artifacts
%     else
%         pixelVal_filt(:,c) = resampledYdata(:,c); % if you dont want to filter, just take the raw input
%     end
% end

%% ICA on different color channels
% Run fastICA to correct for motion
finalSignal=fastICA_analysis_2(signalProcessing,filt1_struct);

%% Old Code

%finalSignal = struct();
%tic
%finalSignal.comp                = fastica(pixelVal_filt','numOfIC',signalProcessing.ica.nComps,'maxNumIterations',signalProcessing.ica.nIte,'stabilization',signalProcessing.ica.stab,'verbose',signalProcessing.ica.verbose);
%toc
% debugging line for testing

%% Fourier transform and update the signalProcessing structure
[signalProcessing,finalSignal]=GenPowerSpectrum_3(signalProcessing,finalSignal);
%% old code
% signalProcessing.fft.L                  = signalProcessing.samplingRate*length(resampledXdata);
% signalProcessing.fft.NFFT               = 2^nextpow2(signalProcessing.fft.L); % Next power of 2 from length of y
% signalProcessing.fft.freq               = signalProcessing.samplingRate/signalProcessing.fft.NFFT*(0:signalProcessing.fft.NFFT-1);
% signalProcessing.fft.freqInterestRange  = signalProcessing.FOI/60;
% signalProcessing.fft.fRange2            = find(signalProcessing.fft.freq>signalProcessing.fft.freqInterestRange(1) & signalProcessing.fft.freq<signalProcessing.fft.freqInterestRange(2));
% signalProcessing.fft.HRRange            = 60*signalProcessing.fft.freq(signalProcessing.fft.fRange2);
% 
% finalSignal.powerVal     = [];
% for co = 1:signalProcessing.ica.nComps
% 
%     Y                 = fft(finalSignal.comp(co,:),signalProcessing.fft.NFFT); % calculate frequency spectrum
%     finalSignal.powerVal(:,co)    = Y.*conj(Y)/signalProcessing.fft.NFFT;
% 
% end

%% Low-pass filter fourier spectrum
finalSignal =LowPass_PSDCoherence_4(signalProcessing,finalSignal);  % This filter looks like it is appllied on the actual power spectra

% old code
% finalSignal.coherenceVal = [];
% for co = 1:signalProcessing.ica.nComps
%     if signalProcessing.lowPassPSDFilter.active
%         finalSignal.powerVal(:,co) = filtfilt(signalProcessing.lowPassPSDFilter.NthOrder,signalProcessing.lowPassPSDFilter.cutOffFreq,finalSignal.powerVal(:,co));
%     end
% 
%     finalSignal.coherenceVal(:,co) = finalSignal.powerVal(:,co)./sqrt(sum(finalSignal.powerVal(signalProcessing.fft.fRange2,co).^2));
% %     finalSignal.coherenceVal(:,co) = finalSignal.powerVal(:,co)./sqrt(sum(finalSignal.powerVal(:,co).^2));
% 
% end

%% Extract HR
% Find best channel either based on Best Power ( Highest) or coherence
% (highest periodicity)
[finalSignal]=Coherence_Power_HRanalysis_5(signalProcessing,finalSignal);
finalSignal.t_total=toc(t_start);

%% old code
% finalSignal.maxPower        = [];
% finalSignal.maxCoherence    = [];
% tempMaxPowerIdx             = [];
% tempMaxCoherenceIdx         = [];
% for co = 1:signalProcessing.ica.nComps
%     [finalSignal.maxPower(co),tempMaxPowerIdx(co)] = max(finalSignal.powerVal(signalProcessing.fft.fRange2,co));
%     [finalSignal.maxCoherence(co),tempMaxCoherenceIdx(co)] = max(finalSignal.coherenceVal(signalProcessing.fft.fRange2,co));
% end
% [~,tempMaxPowerCompIdx] = max(finalSignal.maxPower);
% [~,tempMaxCoherenceCompIdx] = max(finalSignal.maxCoherence);
% 
% finalSignal.HRfreqIdx_powerBased    = tempMaxPowerIdx(tempMaxPowerCompIdx);
% finalSignal.HR_powerBased           = signalProcessing.fft.freq(signalProcessing.fft.fRange2(tempMaxPowerIdx(tempMaxPowerCompIdx)))*60;
% finalSignal.HR_powerBased_PerComp   = signalProcessing.fft.freq(signalProcessing.fft.fRange2(tempMaxPowerIdx))*60;
% finalSignal.HRBestCompIdx_powerBased    = tempMaxPowerCompIdx;
% 
% finalSignal.HRfreqIdx_coherenceBased    = tempMaxCoherenceIdx(tempMaxCoherenceCompIdx);
% finalSignal.HR_coherenceBased           = signalProcessing.fft.freq(signalProcessing.fft.fRange2(tempMaxCoherenceIdx(tempMaxCoherenceCompIdx)))*60;
% finalSignal.HR_PerComp_coherenceBased   = signalProcessing.fft.freq(signalProcessing.fft.fRange2(tempMaxCoherenceIdx))*60;
% finalSignal.HRBestCompIdx_coherenceBased    = tempMaxCoherenceCompIdx;
%% If Visualization Flag is on
if visualization_flag==1 % visualize face
Visualize_init_Fourier_Response(signalProcessing,finalSignal)
end
out_struct=buffer_main(buffer_struct,signalProcessing,finalSignal,interp_struct);
%% plot frequency spectrum
%%  Old Code
%%%%% %  Debugging Rahul-- Each component individually
% figure;
% subplot(2,2,1)
% plot(signalProcessing.fft.HRRange,finalSignal.powerVal(signalProcessing.fft.fRange2,1));
% title("Component 1--Power")
% 
% subplot(2,2,2)
% plot(signalProcessing.fft.HRRange,finalSignal.powerVal(signalProcessing.fft.fRange2,2));
% title("Component 2--Power")
% 
% subplot(2,2,3)
% plot(signalProcessing.fft.HRRange,finalSignal.powerVal(signalProcessing.fft.fRange2,3));
% title("Component 3--Power")

%% %%%%%%%%


% figure();
% subplot(2,2,1);
% plot(signalProcessing.fft.HRRange,finalSignal.powerVal(signalProcessing.fft.fRange2,:));
% hold on
% line([repmat(finalSignal.HR_powerBased,1,2)],[0 max(finalSignal.powerVal(signalProcessing.fft.fRange2,finalSignal.HRBestCompIdx_powerBased))],'Color','k','LineStyle',':','LineWidth',2)
% xlabel('HR')
% ylabel('Power')
% 
% subplot(2,2,2)
% plot(signalProcessing.fft.HRRange,finalSignal.coherenceVal(signalProcessing.fft.fRange2,:));
% hold on
% line([repmat(finalSignal.HR_coherenceBased,1,2)],[0 max(finalSignal.coherenceVal(signalProcessing.fft.fRange2,finalSignal.HRBestCompIdx_coherenceBased))],'Color','k','LineStyle',':','LineWidth',2)
% xlabel('HR')
% ylabel('Coherence')
% legend('Component 1','Component 2','Component 3')
% 
% subplot(2,2,4);
% plot(resampledXdata,finalSignal.comp(finalSignal.HRBestCompIdx_coherenceBased,:),'k')
% title('Best component - coherence based')
% ylabel('Pixel val')
% xlabel('Time [s]')




%% Time frequency analysis
% 
% computerCoherence = 1; % 0 = raw data, 1 = coherence transformed
% 
% winSize     = 10;   % X seconds
% tempRes     = 240;  % temporal resolution, number of time points - THIS NEEDS TO BE CHANGED TO NUMBER OF POINTS PER SECOND
% % added by RR How many separate readings
% freqRes     = 120;  % frequency resolution, number of frequencies
% 
% %% We use a sliding window approach once agian similar to the NIR structure sensor system
% 
% winSize = winSize*ceil(signalProcessing.samplingRate);
% tBins   = floor(linspace(1,length(finalSignal.comp)-winSize,tempRes));
% fvec    = linspace(signalProcessing.FOI(1)/60,signalProcessing.FOI(2)/60,freqRes);
% 
% timeFreqData = NaN(length(fvec),length(tBins));
% tData = NaN(1,length(tBins));
% countT = 0;
% for tt = tBins % move over by tempRes every time
%     countT = countT+1;
%     t = tt:tt+winSize;
%     [timeFreqData(:,countT),fvec2] = plomb(finalSignal.comp(finalSignal.HRBestCompIdx_powerBased,t),resampledXdata(t),fvec);
% %     [timeFreqData(:,countT),fvec2] = plomb(finalSignal.comp(finalSignal.HRBestCompIdx_coherenceBased,t),resampledXdata(t),fvec);
%     tData(countT) = mean(resampledXdata(t));
%     
%     if computerCoherence
%         timeFreqData(:,countT) = timeFreqData(:,countT)./sqrt(sum(timeFreqData(:,countT)).^2);
%     end
%     
% end
% 
% % signalProcessing.lowPassHRTimeFilter.params = [8 0.03];  % [int 0.01-0.10] butterworth parameters [Xth_order cutoff_freq]
% % [signalProcessing.lowPassHRTimeFilter.NthOrder,signalProcessing.lowPassHRTimeFilter.cutOffFreq] = butter(signalProcessing.lowPassHRTimeFilter.params(1),signalProcessing.lowPassHRTimeFilter.params(2));
%         
% figure();
% imagesc(timeFreqData)
% hold on
% [~,maxIdx] = max(timeFreqData);
% line(1:length(maxIdx),maxIdx,'Color','g','LineWidth',3,'LineStyle',':')
% 
% if signalProcessing.lowPassHRTimeFilter.active
%     maxIdx_filt = filtfilt(signalProcessing.lowPassHRTimeFilter.NthOrder,signalProcessing.lowPassHRTimeFilter.cutOffFreq,maxIdx);
%     
% end
% line(1:length(maxIdx_filt),maxIdx_filt,'Color','b','LineWidth',3)
% %% Added by Rahul
% for i=1:length(maxIdx_filt)
% Final_Results.HR_Filt(i)=60*interp1([1:length(fvec2)],fvec2,maxIdx_filt(i));
% Final_Results.HR_NoFilt(i)=60*interp1([1:length(fvec2)],fvec2,maxIdx(i));
% 
% end
% Final_Results.time=(tBins+winSize)*(1/ceil(signalProcessing.samplingRate));
% %%
% 
% set(gca,'xtick',round(linspace(1,length(tBins),5)))
% set(gca,'xticklabel',round(tData(round(linspace(1,length(tBins),5)))))
% 
% set(gca,'ytick',round(linspace(1,length(fvec),10)))
% set(gca,'yticklabel',round(60*fvec(round(linspace(1,length(fvec),10)))))% The y tick is differet..
% 
% % Scaled based on fvec
% xlabel('Time (s)')
% ylabel('Heart rate (bpm)')
% colormap('hot')
% 
