function [Masked_Images,pixelValPerFrame,t_mask]=K_Means_Masking(image_struct,DetectedFaceStruct)
%% Mask Each Image using K-Means. Return Masked_Images(images actually masked) as well as mean of the pixels
for i=1:length(DetectedFaceStruct) % each frame
    tic_1=tic;
    Im=image_struct.images(:,:,:,i);
    %tic
    [out_struct,out_im,skinImB_3] = selectFaceTemplateColorCluster_VZ_Ver(DetectedFaceStruct{i}, Im);
    %toc
    out_im(~skinImB_3)=0; % Masked Image
    Masked_Images{i}(:,:,:)=uint8(out_im);
    for j=1:3 % each channel--RGB
        %pixelValPerFrame(i,j)=mean(mean(Masked_Images{i} (:,:,j)));
         pixelValPerFrame(i,j)=mean(mean(nonzeros(Masked_Images{i} (:,:,j)))); % nonzero mean
    end
    t_mask(i)=toc(tic_1);
end
end