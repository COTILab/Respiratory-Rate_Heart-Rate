function images_struct=BlackFly_TakeImg(vid,num_frames)
%% 24SEP21
% Takes images First. We will Crop and excise images SEPARATELY
try
vid.FramesPerTrigger = num_frames;% how many frames will we throw away..  round(Init_tc/(1/fs_est));
catch
disp("Frames per trigger already set. we will continue")
end
% exp time is provided in ms





try % if started we keep going
    start(vid)
catch
    disp("Camera started but we will keep going")
end
tStart=tic;
% tic
% rahul=getsnapshot(vid);
% toc
toc2=toc(tStart);
rahul=tic;
trigger(vid)

%disp("ARBITUARY PAUSE BASED ON EXP TIME SO WE WONT CRASH");pause((exp_time/1000)*num_frames*2);

% need a loop here so that we pause until we can successfully get
% data
bp=1; % break point variable
while(bp==1)
    %get(vid,'FramesAvailable')
    if(get(vid,'FramesAvailable')==num_frames)
        rahulr=toc(rahul)
        [temp,ts]=getdata(vid,num_frames);
        bp=0; % break out of loop
    end
    %disp("Images not acquired yet-pausing to allow for completion")
    %pause(1)
    %pause(0.1)
end
images=squeeze(double(temp));
%pause(delay)

%images(:,:,i)=(temp);
%time_stamp=toc(tStart)-toc2;
%




%images_struct.time_stamp=linspace(0,time_stamp,num_frames);
mean_time=mean(diff(ts));
images_struct.time_stamp=linspace(0,mean_time*num_frames,num_frames);
images_struct.raw_time_stamps=ts;

%images_struct.time_stamp=linspace(exp_time/1000,(exp_time/1000)*num_frames,num_frames); %
images_struct.images=images;
images_struct.time_inc=diff(images_struct.time_stamp);
images_struct.frame_rate_est=mean(images_struct.time_inc);
images_struct.frame_std=std(diff(images_struct.time_stamp),0,2);
images_struct.fs_est=1/images_struct.frame_rate_est;
images_struct.total_analysis_time=toc(tStart);
stop(vid);

end