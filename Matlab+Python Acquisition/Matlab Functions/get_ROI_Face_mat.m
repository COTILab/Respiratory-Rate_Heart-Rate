function ROI=get_ROI_Face_mat(img,sf,mn)
% Written on 15SEP21
% Uses openCV to determine Bounding box on face

%% Inputs:
%1. img: Gray scale image; Script automatically converts later on
% 2.sf-->scalingFactor: cv2.CascadeClassifier attribute. Relates to image
% scaling at every step. Determines quality of fit/ if we fit
% 3 mn-->minNeighbors: elemet of cv2.CascadeClassifier 

temp=uint8(img);
temp_3=cat(3,temp,temp,temp);
%sf=1.2;mn=3; % face parameters
[face_dims]=(py.CameraFunctions.get_ROI_FACE(temp_3,sf,mn)); % give RGB image even though its grayscale
for i=1:size(face_dims,1)
    for j=1:size(face_dims,1)
        temp=uint32(face_dims{i,j});
        face_dims_conv(i,j,:)=temp;
    end
end
face_dims_conv=squeeze(face_dims_conv);
ROI=face_dims_conv;