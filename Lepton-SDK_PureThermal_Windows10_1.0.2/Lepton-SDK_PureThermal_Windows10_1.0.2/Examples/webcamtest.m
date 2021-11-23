close all
clear all
clc
%%
info = imaqhwinfo('winvideo', 1);
info.SupportedFormats

%%
% Typically you want y16
num_frames=1;
%% Gray scale
vid = videoinput('winvideo', 2, 'Y16 _160x120');%videoinput('winvideo', 1, 'Y16 _160x120');
src = getselectedsource(vid);
triggerconfig(vid, 'manual');
vid.FramesPerTrigger = num_frames;
start(vid)
trigger(vid)
[images_gs,ts_gs]=(getdata(vid,num_frames));
stop(vid);
%% RGB
vid_2 =videoinput('winvideo', 2, 'RGB24_160x120');%videoinput('winvideo', 1, 'Y16 _160x120');
src_2 = getselectedsource(vid_2);
triggerconfig(vid_2, 'manual');
vid_2.FramesPerTrigger = num_frames;
start(vid_2)
trigger(vid_2)
[images_rgb,ts_rgb]=(getdata(vid_2,num_frames));

figure;subplot(1,3,1);imagesc(images_gs);colorbar
subplot(1,3,2);imshow(images_rgb);colorbar
subplot(1,3,3),imagesc((flip(rgb2gray(images_rgb),1))),colorbar


% images=squeeze(images);
% time_inc=diff(ts);
% frame_rate_est=1/mean(time_inc);
% figure;subplot(2,1,1);p1=imagesc(images(:,:,1));colorbar
% target_pix=[27 37 71 85];
% clear sub_img temp key_vec
% s_idx=1; % starting frame to visualze
% e_idx=50;% ending frame to visualize
% for i=s_idx:e_idx%size(images,3) % each frame
%     set(p1,'CData',images(:,:,i));
%     sub_img(:,:,i)=images(target_pix(1):target_pix(2),target_pix(3):target_pix(4),i);
%     if i==s_idx
%         subplot(2,1,2);p2=imagesc(sub_img(:,:,i));colorbar
%     else
%         set(p2,'CData',sub_img(:,:,i))
%     end
%     temp=sub_img(:,:,i);
%     key_vec(i-s_idx+1)=mean(temp(:));
%     drawnow
%     pause(0.1)
%     title(i)
% end
% figure;plot(key_vec);
    
%%
% Here's a 3d whatever it's called
%preview(vid)
frame = getsnapshot(inp);
[X,Y] = meshgrid(1:size(frame, 2), 1:size(frame, 1));
figure
msh = mesh(X, Y, frame);

%%
% loop over this again and again
% creating a live temperature model
for x =0:300
    frame = getsnapshot(inp);
    set(msh, "ZData", frame)
end