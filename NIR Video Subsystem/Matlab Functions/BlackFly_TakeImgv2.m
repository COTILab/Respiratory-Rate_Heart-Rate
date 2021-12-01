function images_struct=BlackFly_TakeImgv2(vid,num_frames,varargin)
%% 24SEP21
% Takes images First. We will Crop and excise images SEPARATELY
% Use FramesAcquiredFcn callbacks for more consistency --> Increased speed
% https://www.mathworks.com/matlabcentral/answers/97183-how-do-i-save-a-continuous-stream-of-video-to-a-series-of-short-video-files-using-image-acquisition
src = getselectedsource(vid);
if length(varargin)==1
    cam_init_flag=varargin{1};
else
    cam_init_flag=0; % cam is NOT INITIALIZED
end
persistent internal_buffer_length
if cam_init_flag==0
    internal_buffer_length=300; % buffer will always be equal to initial number frames. We apply a generous scaling factor to ensure we still run OR SMALLER than this value
    if num_frames==1
    internal_buffer_length=1; disp("Internal Buffer set to 1 BF")% for live video
    end
end

if cam_init_flag==0 % camera is NOT INITIALIZED
    try
        vid.FramesPerTrigger = internal_buffer_length;% % BUFFER WILL BE BIGGER THAN WHAT WE WANT  how many frames will we throw away..  round(Init_tc/(1/fs_est));
        %set(vid,'FramesAcquiredFcn',{@FrameSave},'FramesAcquiredFcnCount',num_frames);
    catch
        disp("Frames per trigger already set. we will continue")
    end
    % exp time is provided in ms
    
    
    
    
    
    try % if started we keep going
        start(vid)
    catch
        disp("Camera started but we will keep going")
    end
end% WE ONLY DO THAT IF CAMERA IS NOT INITIALIZED
tStart=tic;
% tic
% rahul=getsnapshot(vid);
% toc
toc2=toc(tStart);
rahul=tic;
if cam_init_flag==0 % WE HAVE TO TRIGGER HERE
    trigger(vid)
end

%disp("ARBITUARY PAUSE BASED ON EXP TIME SO WE WONT CRASH");pause((exp_time/1000)*num_frames*2);

% need a loop here so that we pause until we can successfully get
% data
bp=1; % break point variable
%ctr=1;
%temp2=[0 0];
%b_v=0; % we are breaking this loop
while(bp==1)
    temp2=get(vid,'FramesAvailable');
    %get(vid,'FramesAvailable')
    % WE PAUSE HERE WHEN WAITING FOR BUFFER TO FILL WE NEED TO FIX EDGE
    % CASE
    %temp2(ctr)=get(vid,'FramesAvailable');
    if(get(vid,'FramesAvailable')>=num_frames)
        % need to catch edge case
        
        rahulr=toc(rahul);
        [images,ts]=getdata(vid,num_frames);
        
        bp=0; % break out of loop
        
    end
    %disp("Images not acquired yet-pausing to allow for completion")
    %pause(1)
    %pause(0.1)
    pause(src.ExposureTime/10^6 + 0.15) % pausing is related to exp time WE SHOULD BE GAINING IMAGES UNLESS WE EXTRACTD IMAGES.. WE BREAK IN THAT CASE
    temp3=get(vid,'FramesAvailable');
    if (temp2==temp3&&bp==1) %
        try
            trigger(vid)
        catch % This only happens if there is a memory error with camera. in this case we have to rstart the camera
            start(vid)
            trigger(vid)
        end
        %pause((num_frames/2)*(src.ExposureTime/10^6 + 0.05))
    end
end
images=squeeze((images));
%images=squeeze(log(abs(double(images)))); disp("LOG OF DATA")
%pause(delay)

%images(:,:,i)=(temp);
%time_stamp=toc(tStart)-toc2;
%




%images_struct.time_stamp=linspace(0,time_stamp,num_frames);
mean_time=mean(diff(ts));
images_struct.time_stamp=linspace(0,mean_time*num_frames,num_frames);
images_struct.raw_time_stamps=ts;

%images_struct.time_stamp=linspace(exp_time/1000,(exp_time/1000)*num_frames,num_frames); %
%images_struct.images=images;
images_struct.images=permute(images,[2 1 3]); disp("Transposing Images")
images_struct.dim1=size(images_struct.images,1);
images_struct.dim2=size(images_struct.images,2);
images_struct.time_inc=diff(images_struct.time_stamp);
images_struct.frame_rate_est=mean(images_struct.time_inc);
images_struct.frame_std=std(diff(images_struct.time_stamp),0,2);
images_struct.fs_est=1/images_struct.frame_rate_est;

%stop(vid);
%if get(vid,'FramesAvailable')<internal_buffer_length % only trigger if we DO NOT have enough frames
%    trigger(vid); % we trigger now.. This makes it so the moment we call this function again, WE ALREADY HAVE IMAGES
%    pause(0.2) % ample pause to even out our acquisition timings more
%end
disp(strcat("WOW:",num2str(get(vid,'FramesAvailable'))))
images_struct.total_analysis_time=toc(tStart);
end
