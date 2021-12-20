close all
clear all
clc
%% 15DEC21
%% add path
addpath(genpath('./FLIR_recorded_videos'));
addpath(genpath('./Thermal_VZ_Functions'));
addpath(genpath('../NIR Video Subsystem'));
%% Video Name
%% CHANGE THIS
% Recorded Path:C:\Users\rahul\OneDrive - Northeastern University\Optical Remote Vital Sensing (ORVS)\Thermal Video Subsystem\FLIR_recorded_videos
AVI_name='Normal_Breathing_1.avi';  % which AVI to read
vis_flag=1 ; % if 1 we visualize EVERYTHING
fs=15; % what we spline to 
%%
%% Face Detector 
%% scaling factor,block size, point tracker, Face detector etc initialization
Refresh_ROI_Frames=1;% How many frames do we want to recalculate the ROI
sf=1.04; % Lower =Higher chance of catching face BUT more computationally expensive+ higher false positives
num_pyr=5; % higher= better tracking but slower
bl_sz=57; % MUST BE ODD NUMBER
KLT_conf=0.8; % what value we drop below before we use cascade detector, Higher value=more accurate but slower
%% initializing trackers-- We have a chest KLT tracker if WE WANT to use it but it may not be necessary
pointTracker_Face = vision.PointTracker('BlockSize',[bl_sz bl_sz],'NumPyramidLevels',num_pyr);
pointTracker_Chest=vision.PointTracker('BlockSize',[bl_sz bl_sz],'NumPyramidLevels',num_pyr);
faceDetector = vision.CascadeObjectDetector('ScaleFactor',sf(1)); % initializing
%% Other detectors added for testing-- Did not work..
%mouthDetector = vision.CascadeObjectDetector('Mouth'); % initializing
%noseDetector = vision.CascadeObjectDetector('Nose'); % initializing
%im=raw_struct.images(:,:,1);im_rs=imresize(im,3);
%bb_f=step(faceDetector,im_rs)

% frames to read
frames_to_read=[1 0]; % 0 means end of video
disp(" Frames at beginning are tossed out for analysis!!!")

raw_struct=Extract_Frames(AVI_name,frames_to_read);
roi_fixed= [60 75 35 25]; %% Normal_Breathing_1
%[50 50 56 66];%[50 30 50 61]; %;%[50 50 46 66] -30bpm;  %% cant use tracking right now.. dont know why...
if vis_flag==1
%Visualize_Frames(raw_struct.images,roi_fixed) % every frame
Visualize_Frames(raw_struct.images(:,:,1),roi_fixed)
end
%% Mask based on FIXED ROI
masked_struct=Generate_Face_Mask(raw_struct,roi_fixed);

%% Further mask based on statistics( statistics mask== SM)
SM_struct=Generate_Statistics_Mask(masked_struct);
if vis_flag==1
    Visualize_Statistics_Mask(masked_struct.masked_img,SM_struct.sm_img)
end
    
%% spline signal first
splined_struct=Thermal_Spline_Data(SM_struct, fs);
Raw_Fourier_Data=Fourier_Representation(fs,splined_struct.new_times,splined_struct.splined_oned);
%% Filter Creation
bp_mat=[0.1 0.8];
%bp_mat{1}=[0.6 3.5];bp_mat{2}=[0.1 0.8]; % PER BOUNDING BOX
 % Use estimated frame rate here
Wn=(2/fs).*bp_mat; % normalize freqs-- based on nyquist
n=127; % how any points on hamming window and the order
b=fir1(n,Wn,hamming(n+1));
fvtool(b,1,'Fs',fs) % visualizing bandpass
%% EMD Decomposition
orig_signal{1}=splined_struct.splined_oned;
[recon_signal,imf,info,residual,imf_idx_1,imf_idx_2]=  EMD_Analysis_MULTIPLEROIS(orig_signal);
splined_struct.EMD_filt_signal=filter(b,1,recon_signal{1});
%% EMD Reconstruction Plot
figure;plot(splined_struct.new_times,recon_signal{1})
hold on
plot(splined_struct.new_times,splined_struct.EMD_filt_signal)

xlabel('time(seconds')
ylabel('Counts')
legend('EMD Reconstructed-All Components', 'Reconstructed+ Filtered')
%% Filtering+ Fourier Representation
Filtered_EMD_Fourier_Data=Fourier_Representation(fs,splined_struct.new_times,splined_struct.EMD_filt_signal);
Filtered_EMD_Fourier_Data.bpm=60*Filtered_EMD_Fourier_Data.freq_max;
figure;plot(Filtered_EMD_Fourier_Data.freq_fft*60,Filtered_EMD_Fourier_Data.freq_amp)
xlabel("Breaths per Minute")
ylabel("Intensity")
title(strcat("Final Fourier Data-",num2str( Filtered_EMD_Fourier_Data.bpm)))



% %% Applying filter
% splined_struct.filt_signal=filter(b,1,splined_struct.splined_oned);
% %% additional cutting
% cut_time=6; % first time to read
% cut_frame=round(cut_time/(1/fs)); 
% filt_time_cut=splined_struct.new_times(cut_frame:end);
% filt_signal_cut=splined_struct.filt_signal(cut_frame:end);
% 
% Filtered_FourierCUT_Data=Fourier_Representation(fs,filt_time_cut,filt_signal_cut);
% Filtered_FourierCUT_Data.bpm=60*Filtered_FourierCUT_Data.freq_max;
% 
% 
% %% No cutting
% Filtered_Fourier_Data=Fourier_Representation(fs,splined_struct.new_times,splined_struct.filt_signal);
% Filtered_Fourier_Data.bpm=60*Filtered_Fourier_Data.freq_max;
%% Relevant functions i wrote from NIR toolbox
%function Fourier_Data=Fourier_Representation(fs,time_stamps,time_signal)
% INPUTS: 
%1. fs=sampling frequency in Hz
%2. time_stamps=Time entries in seconds-- This is 
%3. time_singal=counts corresponding to time_stamps




% Need an extra arg at end for thermal camera
%%[DetectedFaceStruct,~,detail_struct]=GetFaceandChestROI(raw_struct,faceDetector,pointTracker_Face,pointTracker_Chest,KLT_conf,Refresh_ROI_Frames,1);

