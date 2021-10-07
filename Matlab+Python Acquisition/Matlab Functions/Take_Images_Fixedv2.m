function images_struct=Take_Images_Fixedv2(VideoStreams,num_frames,delay,dim1,dim2)
%written on 09SEP21

% Takes images with ST01 Structure Sensor using python interfacing
% INPUT: 
% VideoStreams: Videostreams python object for openNI
%num_frames: Number of frames we take
%fs_est : frame rate est( hz)
% dim1: resoluton of camera x
% dim2; resolution of camera y
% OUTPUT:
%images_struct: with fields:
% images: taken as 3D array; 3rd dim is number of frames
% total_time_taken: time for all frames
% time_stamp
%exp_time=1/fs_est; % expected delay. should 
%t=tic;
mod=py.importlib.import_module('CameraFunctions'); % import python module
py.setattr(mod,'delay',delay) % setting global variables because python cant take 2 inputs from matlab for som reason...
py.setattr(mod,'num_frames',num_frames)
global_test=py.CameraFunctions.get_globals; % returns globals for debugging...
pyt_out=py.CameraFunctions.take_IR_imagevtwo(VideoStreams);
%for i=1:num_frames
%internal_t=tic;
%Image_Frame=py.CameraFunctions.take_IR_image(VideoStreams);
%t2_end=toc(t); % recording time stamp as soon as we take an image
%internal_t_end(i)=toc(internal_t);
%%if internal_t_end<exp_time % if we take frames too fast
%    var_delay(i)=exp_time-internal_t_end;
%    pause(var_delay(i)) % variable delay to match expected frame rate except whn we have hitches
%end
%t3_end(i)=toc(t);
%pause(0.0025);% adding a short delay to FORCE INTERPOLATION
%Image_Frames{i}=Image_Frame;
%Image_Frame_mat(:,:,i)=uint16(Image_Frame);
%Image_Frame_rs(:,:,i)=reshape(Image_Frame_mat,dim1,dim2); % images currently fixed at 320 x240. If this changes, we can update dim1 and dim2
%t4_end(i)=toc(t); % just for tstng to see how long reshaping lasts
%images_struct.time_stamp(i)=t3_end(i);%t2_end;
%dend
images_struct.images=double(pyt_out{1});%Image_Frame_rs;
images_struct.time_stamp=double(pyt_out{2});
% estimate frame rate+ return average and standard deviaton of images taken
images_struct.time_inc=diff(images_struct.time_stamp);
images_struct.frame_rate_est=mean(diff(images_struct.time_stamp));
images_struct.frame_std=std(diff(images_struct.time_stamp),0,2);
images_struct.fs_est=1/images_struct.frame_rate_est;
end