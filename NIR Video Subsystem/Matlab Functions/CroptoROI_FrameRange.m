function [Avg_ROI,Avg_ROI_vec,new_time_stamps,Last_Image]=CroptoROI_FrameRange(image_struct,roi,frame_s_c,varargin)
if length(varargin)>0
    frame_end=varargin{1}; % specify end frame if it exists
else
    frame_end=size(image_struct.images,3); % end frame
    
end

ROI_dim1_start=roi(2);%100;;%85;%126;
ROI_dim1_end=roi(2)+roi(4);%182;%144;
ROI_dim2_start=roi(1);%136;%86;%161;
ROI_dim2_end=roi(1)+roi(3);%193;%183;%176;

Avg_ROI=image_struct.images(ROI_dim1_start:ROI_dim1_end,ROI_dim2_start:ROI_dim2_end,frame_s_c+1:frame_end);

if frame_s_c~=0
new_time_stamps=image_struct.time_stamp(frame_s_c+1:frame_end)-image_struct.time_stamp(frame_s_c);
else
new_time_stamps=image_struct.time_stamp;
end
Avg_ROI=double(Avg_ROI);
%mean_image=nanmean(Avg_ROI,3);
tempFWHM = (nanmedian(Avg_ROI(:)));
for i=1:size(Avg_ROI,3) % every frame
    %temp=Avg_ROI(:,:,i);
    %Avg_ROI_vec(i)=mean(temp(:));
    
    temp = (Avg_ROI(:,:,i));
    
    temp(temp <= (tempFWHM/2)) = NaN; 
    if i==1
        disp("WE ARE MASKING PIXELS") 
    end
    Avg_ROI(:,:,i) = temp;
    Avg_ROI_vec(i) = nanmean(temp(:));
end
Last_Image=Avg_ROI(:,:,end);

%print("ya")