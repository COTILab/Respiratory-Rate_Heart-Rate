function Visualize_Face_Data(image_struct,DetectedFaceStruct,Masked_Images)
%% Written on 18NOV21
% Input
% 1.image_struct: input images and structure
% 2.DetectedFaceStruct: Structure with bounding boxes... uses the same
% syntax as BlackFly NIR system

% Outputs: Nothing. Just for plotting


%% For now use k means

%[faceIm,skinImB_3] = selectFaceTemplateNoEyes(skinDetection, Im); % K means method
figure;
nrows=2;
ncols=1;
for i=1:size(image_struct.images,4)
subplot(nrows,ncols,1)
imshow(image_struct.images(:,:,:,i));
hold on
rectangle('Position',DetectedFaceStruct{i}.newBBox,'EdgeColor','r','LineWidth',4);
title(strcat("Full Face-Frame: ",num2str(i)));

subplot(nrows,ncols,2) %% Masked
imshow(Masked_Images{i});
title(strcat("Masked Image-Frame: ",num2str(i)));
drawnow
pause(0.1);


end