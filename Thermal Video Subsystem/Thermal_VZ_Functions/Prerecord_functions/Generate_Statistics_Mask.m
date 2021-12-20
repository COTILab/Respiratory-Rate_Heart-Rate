function final_struct=Generate_Statistics_Mask(masked_struct)
%15DEC21: Generate mask based on statistics. We want this mask to do the
%following: 1. Pick the nose region ( for nose breathers) or mouth region (
%for mouth breathers) and 2. throw out all other pixels. Cleanest signal
%possible is desired
i_img=single(masked_struct.masked_img); % init image-- should be mostly the face+ some background that is a lower value
corr_struct=Correlation_Masking(i_img);
ori=i_img; % original face images
mean_pixels=nanmean(i_img,3);
sf_1=10; % normalized pixel cutoff based on percentile. 25 means we cut out 25% of pixels  
cut_off=prctile(mean_pixels(:),sf_1);
i_img_mask_idx=mean_pixels>cut_off;
%i_img(~i_img_mask_idx)=NaN;
for i=1:size(i_img,3)
   temp=i_img(:,:,i);
    temp(~i_img_mask_idx)=NaN;
    i_img(:,:,i)=temp; % mask at every layer
end
% first mask 


std_pixels=nanstd(single(i_img),0,3);
sf_2=90; % normalized pixel cutoff based on percentile. 25 means we cut out 25% of pixels  
cut_off_2=prctile(std_pixels(:),sf_2);
i_img_mask_idx_2=std_pixels>cut_off_2;

for i=1:size(i_img,3) % masking based on Std
   temp=i_img(:,:,i);
    temp(~i_img_mask_idx_2)=NaN;
    i_img(:,:,i)=temp; % mask at every layer
    oned_signal(i)=nanmean(temp(:));
end


%stat_pixels=std_pixels./mean_pixels;
final_struct=masked_struct
final_struct.sm_img=i_img;
final_struct.oned_signal=oned_signal;

end