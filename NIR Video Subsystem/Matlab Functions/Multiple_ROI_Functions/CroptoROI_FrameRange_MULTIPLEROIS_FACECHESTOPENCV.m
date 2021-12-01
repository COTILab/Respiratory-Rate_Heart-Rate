function [Avg_ROI,Avg_ROI_vec,new_time_stamps,Last_Image]=CroptoROI_FrameRange_MULTIPLEROIS_FACECHESTOPENCV(image_struct,mult_roi,frame_s_c,varargin)
if length(varargin)>0
    frame_end=varargin{1}; % specify end frame if it exists
else
    frame_end=size(image_struct.images,3); % end frame
    
end
for j=1:length(mult_roi)
    AllData{j}=[NaN];
    
end


idx=1;

for i=1:size(mult_roi{1},1) % every frame
    for j=1:length(mult_roi) % how many differnt rois do we have
        roi_num=mult_roi{j};
        roi=roi_num(i,:);
        
        ROI_dim1_start=roi(2);%100;;%85;%126;
        ROI_dim1_end=roi(2)+roi(4);%182;%144;
        ROI_dim2_start=roi(1);%136;%86;%161;
        ROI_dim2_end=roi(1)+roi(3);%193;%183;%176;
        
        Avg_ROI{j,i}=image_struct.images(ROI_dim1_start:ROI_dim1_end,ROI_dim2_start:ROI_dim2_end,i);
        temp=Avg_ROI{j,i};
        
        AllData{j}=cat(1,AllData{j},temp(:));
        %if frame_s_c~=0
        %new_time_stamps=image_struct.time_stamp(frame_s_c+1:frame_end)-image_struct.time_stamp(frame_s_c);
        %else
        %new_time_stamps=image_struct.time_stamp;
        %end
        %Avg_ROI{i,j}=double(Avg_ROI{i,j});
        %temp2=Avg_ROI{i,j};
        %mean_image=nanmean(Avg_ROI,3);
        %tempFWHM = (nanmedian(temp2(:)));
        %for k=1:size(Avg_ROI{i,j},3) % every frame
        %temp=Avg_ROI(:,:,i);
        %Avg_ROI_vec(i)=mean(temp(:));
        
        %    temp = (temp2(:,:,j));
        
        %    temp(temp <= (tempFWHM/2)) = NaN;
        %    if j==1
        %        disp("WE ARE MASKING PIXELS")
        %    end
        %    temp2(:,:,j) = temp;
        %    Avg_ROI_vec_sing_ROI(j) = nanmean(temp(:));
        %end
        %Avg_ROI{i}=temp2;
        %Avg_ROI_vec{i}=Avg_ROI_vec_sing_ROI;
        %Last_Image{i}=temp2(:,:,end);
        %end
        %end
        %print("ya")
    end
    
end

end
