function img_struct=Extract_Frames(AVI_name,varargin)


mov= VideoReader(AVI_name)
ctr=1;
while(hasFrame(mov))
    im=readFrame(mov);
    %r_im= imrotate(im,-90); % ROTATE FOR FACE ORIENTATION
    frames(:,:,ctr) =imrotate(rgb2gray(im),-90) ;
    ctr=ctr+1;
    frame_timing(ctr)=mov.CurrentTime;
    %imshow(frame);
    %title(sprintf('Current Time = %.3f sec', vidObj.CurrentTime));
    %pause(2/vidObj.FrameRate);
end
disp("Note frames are rotated such that face detector will work (upright)")
img_struct.images=squeeze(frames);
img_struct.timings=frame_timing(2:end);
img_struct.time_inc=diff(frame_timing);
%% if varargin is assigned we crop further
if length(varargin)>0
   idx_1=varargin{1}(1); 
   idx_2=varargin{1}(2);
   if idx_2==0 % if set to 0
       idx_2=size(img_struct.images,3); % end of frames
   end
   img_struct.images=img_struct.images(:,:,idx_1:idx_2);
   img_struct.timings=img_struct.timings(idx_1:idx_2)-img_struct.timings(idx_1);
   img_struct.timings=img_struct.timings+img_struct.timings(2); % have to scale so firs value isnt 0..
   %img_struct.timings=img_struct.timings(2:end);
   img_struct.time_inc=diff(img_struct.timings);
   
   
   
    
end


end