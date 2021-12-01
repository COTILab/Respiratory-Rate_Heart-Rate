function [Avg_ROI,new_time_stamps,Avg_ROI_vec,BBox_mat]=CroptoROI_multframes(images,time_stamps,sf,mn,frame_s_c)
for i=1:size(images,3) % first find a SINGLE FRAME WE CAN find a bbox for 
    try
        BBox=get_ROI_Face_mat(uint8(images(:,:,i)),sf,mn);
         if length(BBox)==4 % if 1 face is found
        temp=BBox;
        %i
        break; % break out because we found a frame
         end
        catch
    end
end
%% FROM HERE WE TRY TO APPLY BOUNDING BOX WITH OPEN CV TO AS MANY IMAGES AS WE CAN
for i=1:size(images,3) % each image
    try
    BBox=get_ROI_Face_mat(uint8(images(:,:,i)),sf,mn);
    BBox(fnd(BBox==0))=1; % replace 0 indices;
    
    if length(BBox)==4 % if 1 face is found
        temp=BBox;
    end
    catch
    end
    BBox_mat(:,i)=temp; % if for whatever reason face is no found, we overwrite with the last face
    %     rahul(i)=toc(blah);
    roi=BBox_mat(:,i);
    
    %
    ROI_dim1_start=roi(2);%100;;%85;%126;
    ROI_dim1_end=roi(2)+roi(4);%182;%144;
    ROI_dim2_start=roi(1);%136;%86;%161;
    ROI_dim2_end=roi(1)+roi(3);%193;%183;%176;
    %i
    
    Avg_ROI{i}=images(ROI_dim1_start:ROI_dim1_end,ROI_dim2_start:ROI_dim2_end,i);
    % masking
    temp2 =Avg_ROI{i};
    tempFWHM = (nanmedian(temp2(:)));
    temp2(temp2 <= (tempFWHM/2)) = NaN;
    Avg_ROI{i} = temp2;
    % end masking
    
    Avg_ROI_vec(i)=nanmean(nanmean(double(Avg_ROI{i})));
    
    % removing specified frames up front frames
   
    
    
    
    %end
    
    %disp(i)
end
 new_time_stamps=time_stamps(frame_s_c+1:end);
    Avg_ROI_vec=Avg_ROI_vec(frame_s_c+1:end);
    
end