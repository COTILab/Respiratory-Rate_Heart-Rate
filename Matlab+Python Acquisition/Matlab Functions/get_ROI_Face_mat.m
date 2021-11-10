function [ROI,landmarks]=get_ROI_Face_mat(img,sf,mn,Cascade_outputs)
% Written on 15SEP21
% Uses openCV to determine Bounding box on face

%% Inputs:
%1. img: Gray scale image; Script automatically converts later on
% 2.sf-->scalingFactor: cv2.CascadeClassifier attribute. Relates to image
% scaling at every step. Determines quality of fit/ if we fit
% 3 mn-->minNeighbors: elemet of cv2.CascadeClassifier 
ROI=[];
landmarks=[];

temp=uint8(img);
temp_3= temp;%cat(3,temp,temp,temp);
%sf=1.2;mn=3; % face parameters
%tic

[face_dims]=(py.CameraFunctions.get_ROI_FACE(temp_3,sf,mn,Cascade_outputs{1},Cascade_outputs{2})); % give RGB image even though its grayscale
%toc
ROI_p=face_dims{1};
landmarks_p=face_dims{2};


%% ONLY RETURN LARGEST FACE BY AREA
Area=0;
for i=1:length(ROI_p) % for each face
   temp=uint32(ROI_p{i}); 
   temp_area=temp(3)*temp(4);
   if temp_area>Area
       Area=temp_area;
       key_idx=i; % largest face
   end
   ROI(i,:)=temp;
    
    
end
if exist('key_idx')
ROI= ROI(key_idx,:); % only keep largest ROI by area


j_init=1;
ctr=1;
for i=68*(key_idx-1)+1:68*(key_idx) % for each face
   temp=uint32(landmarks_p{i}); 
   j=1;%ceil((i)/(68)); % 68 landmarks based on map
  % if j>j_init
  %     j_init=j;
  %     ctr=1;
  % end
   landmarks(ctr,:,j)=temp;
    ctr=ctr+1;
    
end

end
%% OLD CODE WITH ONLY BOUDNING BOX, NO LANDMARKS



%for i=1:size(face_dims,1)
%    for j=1:size(face_dims,1)
%        temp=uint32(face_dims{i,j});
%        face_dims_conv(i,j,:)=temp;
%    end
%end
%face_dims_conv=squeeze(face_dims_conv);
%ROI=face_dims_conv;
end