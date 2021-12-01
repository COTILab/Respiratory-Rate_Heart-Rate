 %camera initialization--blackfly using matlab

close all 
clear all 
clc

imaqreset % clear config and stops camera
%% flags
face_det_flag=0; % 1 if we use open CV to locate face, 0 if we want to manually choose ROI
MLSVD_FilterXY_Flag=0; % Filtering images in X and Y using MLSVD
% analysis flags
MLSVD_Analysis_Flag=0; % 1 if we are we analyzing using MLSVD
EMD_Analysis_Flag=1; %  1 if we are analyzing using EMD methods
%% Parameters we fix for analysis
%fs_est=15; % what fs we want, frames per scond
%Analysis_Window_Length=7; % in seconds

%% other settings relatd to camera
exp_time=120;%66.6667;%(1/fs_est)*1000; % exposure time in ms
%
init_tc_frame_count=2;% how many frames will we throw away..  round(Init_tc/(1/fs_est));
Analysis_frame_count=225;%round(Analysis_time/(1/fs_est));% converts time to frames as an estimate-- Rounds to whole number of frames
Refresh_frame_count=15;% Analysis_frame_count;%round(Refresh_time/(1/fs_est)); % coverts time to frames as an estimate-- Rounds to whole number of frames
%time_d=0.1; % delay between images

%% INITIALIZING IR SOURCE IF STRUCTURE SENSOR
%% adding relevant paths
modpath='./Python Functions';
matlabfun_path='./Matlab Functions';
addpath(genpath(modpath));
addpath(genpath(matlabfun_path));
% reload python modules


%
%% Initialization-- Turns on video streams
VideoStreams=Camera_Initialization(modpath); % initialize
py.CameraFunctions.kill_both_streams(VideoStreams) % kill
pause(1)
VideoStreams=Camera_Initialization(modpath); % initialize
%% initializing Blackfly camera
tStart=tic;

%temp_cam_info       = imaqhwinfo('mwspinnakerimaq'); % Find info about system devices
%camList    = {temp_cam_info.DeviceInfo.DeviceName}; % Create list of available video devices
%camera.cam = videoinput('winvideo',1,char(temp_cam_info.DeviceInfo(1).SupportedFormats(9))); % 9 is RGB24_960x540,10 default for YUY2 720x1280--Internal Webcam asus
%camera.cam = videoinput('mwspinnakerimaq',1,char(temp_cam_info.DeviceInfo(1).SupportedFormats(3))); % 9 is RGB24_960x540,10 default for YUY2 720x1280--Internal Webcam asus
disp("Blackfly")


%camera.cam.FramesPerTrigger=1; % 1 frame per trigger
%camprop = getselectedsource(camera.cam);
disp("Set camera properties")
vid = videoinput('mwspinnakerimaq', 1, 'Mono16'); % mono16 image

src = getselectedsource(vid);

% preview(vid);
% 
% stoppreview(vid);
% 
src.ExposureTime = round(exp_time*1000);
% 
% preview(vid);
% 
% stoppreview(vid);
% closepreview

src.GainConversion = 'HCG'; % high conversion gain-- better for low light imaging
src.AdcBitDepth = 'Bit12'; % 12 bit ADC bit depth
vid.ROIPosition = [0 0 1936 1464]; % crop in matlab-- we always look at full image in matlab
%src.AcquisitionFrameCount=1;
%src.ExposureTime = round(exp_time*1000);

triggerconfig(vid, 'manual'); % manual trigger
vid.TriggerRepeat = Inf;
%% Taking specified images USING BLACKFLY
cam_init_flag=0; % initializ camera first
image_struct_first=BlackFly_TakeImgv2(vid,Analysis_frame_count+init_tc_frame_count,cam_init_flag);
cam_init_flag=1; % now it is initialized
%image_struct_first=BlackFly_TakeImg(vid,Analysis_frame_count+init_tc_frame_count);

%% ROI not using open CV 
if face_det_flag==0 % if we want to select an ROI manually
    BBox=Manual_ROI_Selection(image_struct_first.images(:,:,end));
    
end
%% Cropping to ROI
if face_det_flag==0
    [Avg_ROI,Avg_ROI_vec,new_time_stamps]=CroptoROI_FrameRange(image_struct_first,BBox,init_tc_frame_count);
    [Avg_ROI_nfs,Avg_ROI_vec_nfs,ori_time_stamps]=CroptoROI_FrameRange(image_struct_first,BBox,0); % no time cut off
end
%% Debugging dsplaying all images CROPPED
%% VISUALIZING IMAGES--COMMENTED OUT
% figure
% ax1=imagesc(Avg_ROI(:,:,1));colorbar
% for i=1:size(Avg_ROI,3)
%    imagesc(Avg_ROI(:,:,i));colorbar;title(i);
%     %set(ax1,'CData',Avg_ROI(:,:,i))
%    %colorbar
%    %drawnow
%    pause(0.01)
%    
% end
% BP parameters
%%
bp_mat=[0.7 3.5];
Wn=(2/image_struct_first.fs_est).*bp_mat; % normalize freqs-- based on nyquist
n=127; % how any points on hamming window and the order
b=fir1(n,Wn,hamming(n+1));
%% VISUALIZING BANDPASS-COMMENTED OUT
%fvtool(b,1,'Fs',image_struct_first.fs_est) % visualizing bandpass
%%
[recon_signal,imf,info,residual,imf_idx_1,imf_idx_2]= EMD_Analysis(Avg_ROI_vec);disp("WITHOUT SPLINING")
Analyzed_fourier_NOBP=Fourier_Representation(image_struct_first.fs_est,image_struct_first.time_stamp,recon_signal); % no bp
% Create bandpass and apply


filtered_recon=filter(b,1,recon_signal); % APPLYING FILTER
  Analyzed_fourier=Fourier_Representation(image_struct_first.fs_est,new_time_stamps,filtered_recon); % with bandpass
  figure;plot(Analyzed_fourier.freq_fft,Analyzed_fourier.freq_amp)
  
  hr(1)=Analyzed_fourier.freq_max*60; % actual heart rate measurement
  tp(1)=toc(tStart);
  
  %% Adding all relevant settings to struct to then run -- Develops buffer
  % we assume camera is already intialized and ready to take more images
  refresh_cycles=1000; % how many refreshed cycles of data do we want
  %
  Refresh_struct.framestorun=Refresh_frame_count; % How many more frames do we want to run
  Refresh_struct.exc_frames=init_tc_frame_count; % additional images at beginning that we will scrap
  Refresh_struct.BBox=BBox; % Old bounding box
  Refresh_struct.refresh_cycles=refresh_cycles; % how many times we will add to buffer
  Refresh_struct.filter_b=b; % what filter to use 
  Refresh_struct.hr=hr; % initial heart rate prior to buffer
  Refresh_struct.fs_est=image_struct_first.fs_est;  % frame rate estimate
  Refresh_struct.init_buffer=Avg_ROI_vec; % initial buffer
  Refresh_struct.vid=vid; % video object
  Refresh_struct.tStart=tStart; % timer start
  Refresh_struct.timestamps=new_time_stamps; % time stamps. assume same acquisition rate after images taken with refresh rate
  Refresh_struct.tp=tp; % time pt
  Refresh_struct.cam_init_flag=cam_init_flag; % camera is now initialized
  %% Running additional buffer frames and then reanalyzing
  close all
  clear image_struct_first Avg_ROI_nfs Avg_ROI
  output_struct=Blackfly_HRBuffer(Refresh_struct);
  stop(vid)
  clc % clear command line
  %% Showing buffer times. can comment this out later
  figure;plot(output_struct.refresh_analysis_time);xlabel('buffer cycle');ylabel('Time(sec)');
  title(strcat("analysis frames=",num2str(Analysis_frame_count)," Buffer frames=", num2str(Refresh_frame_count)));
  