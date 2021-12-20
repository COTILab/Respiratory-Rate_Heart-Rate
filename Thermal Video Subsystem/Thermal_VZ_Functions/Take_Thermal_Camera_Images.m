function [image_struct]=Take_Thermal_Camera_Images(num_frames,varargin)
%% Written on 03DEC21: Note settings hard coded below pertain to FLIR Lepton 3.5 Camera
%% Based on Function Take_Internal_Webcam_Images.m on VZ_Color_Functions as part of color subsystem
% and its internal Webcam: This is convenient just for testing
%% Inputs
% 1. Num_Frames: Scalar Number of frames
%% Output:
% 1. image_struct; Final struct with fields:
% a. images: Raw RGB Images
% b. ts: time stamps of every image
% c. t_int: increment between images
% d. fs: 1/mean(t_int) --> Estimate of Frame Rate
%% Additional Notes: Currently Exposure is fixed. Will eventually need Exposure to become automatically determined depending on patient and ambient lighting conditons...
% so we dont have to redefine this every time...
if length(varargin)==0
   dead_frames=0; % number of frames we throw out from BEGINNING each time we reinit webcam
else
    dead_frames=varargin{1};
    
end

persistent vid
persistent src

%%
%est_time=(1/7.5)*num_frames;
if isempty(vid) % this happens if it is the FIRST time we call the function
    vid = videoinput('winvideo', 1, 'RGB24_160x120');
    vid.Timeout=Inf;%round(est_time+(0.2*est_time));
    triggerconfig(vid, 'manual');
    src = getselectedsource(vid);
    %% Exposure settings
    %exp_struct=propinfo(src,'Exposure'); % exposure
    %max_exp=max(exp_struct.ConstraintValue); % getting max exposure
    %src.ExposureMode='manual';
    
    %src.Exposure=max_exp; % setting max exposure
    % Trigger frames
    vid.FramesPerTrigger = num_frames+dead_frames;
    % other settings
    %src.BacklightCompensation='off';
    %src.WhiteBalanceMode='manual';
    % changing settings accordingly for internal cam
    %available_res=get(cam,'AvailableResolutions');
    %set(cam,'Resolution',available_res{3})
    %set(cam,'ExposureMode','manual') % manual Exposure
    %set(cam,'Exposure',-3) % max exposure for internal camera
    %set(cam,'WhiteBalanceMode','manual')
    %set(cam,'WhiteBalance',4600)
end
%img=getsnapshot(vid);
img=preview(vid); % checking video preview
%close(img)
try
    if get(vid,'FramesAvailable')<num_frames&&strcmpi(vid.logging,'off')
        start(vid)
        %pause(2)
        trigger(vid)
        disp("Acquisition Started")
        if dead_frames>0
          [dead_images,dead_ts]=(getdata(vid,dead_frames));  
            
        end
    end
catch
end
%bp=0;
%while(bp==0)
%    temp2=get(vid,'FramesAvailable');
%    if temp2>=num_frames


[images_raw,ts]=(getdata(vid,num_frames));
%        bp=1;
%    end
%end
rgb_images=images_raw;
%rgb_images= ycbcr2rgb(images_raw);
images=permute(rgb_images,[2 1 3 4]); % So face is oriented correctly
%% Add to final struct
image_struct.images=images;
image_struct.ts=ts;
image_struct.t_int=diff(ts);
image_struct.fs_est=1/mean(diff(ts));
image_struct.vid=vid; % debugging
% trigger again here so we can save time during analysis
%try
%    if get(vid,'FramesAvailable')==0 % sets limit on internal buffer dedicated to images
%    start(vid)
%    trigger(vid)
%    end
%catch
    
    
end