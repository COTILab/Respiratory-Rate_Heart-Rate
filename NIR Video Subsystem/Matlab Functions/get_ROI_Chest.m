function ROI_Chest=get_ROI_Chest(Face_ROI,landmarks,dim1,dim2)
%% Written on 12OCT21: 
% Takes Face_ROI (1x4 Rectangle coordinates) and landarks ( 68 landmark
% points based on opencv--dlib_68pt_mapping_key.png under ./Python
% Function/dlibdat

%%Inputs
% Face_ROI:1 by 4 vector- ASSUME ONE FACE IN PHOTO
% Landmarks; 68 by 2 vector
%dim1: how big is image dim1
%dim2: how big is image dim2

% Get ROI Coordinates
roi=Face_ROI;

% Face coordinates for bounding box
ROI_dim1_start=roi(2);%100;;%85;%126;
ROI_dim1_end=roi(2)+roi(4);%182;%144;
ROI_dim2_start=roi(1);%136;%86;%161;
ROI_dim2_end=roi(1)+roi(3);%193;%183;%176;

Rectangle_pts_face=[[ROI_dim2_start;ROI_dim1_start;],[ROI_dim2_end;ROI_dim1_start;]...
[ROI_dim2_start;ROI_dim1_end],[ROI_dim2_end;ROI_dim1_end]]';

% %We need to find out what orientation the original face bbox rectange
% %positions are written in 
 landmark_idx=12; % landmark 12 is bottom left of chin
 anchor=landmarks(landmark_idx,:);
 norm_dist=sqrt(sum((Rectangle_pts_face-anchor).^2,2)); % which end of ROI is closest to anchor point

 [min_dist,min_idx]=min(norm_dist);
 
 landmark_idx2=27; % landmark 27 is top right eyebrow of chin
 anchor2=landmarks(landmark_idx2,:);
 norm_dist2=sqrt(sum((Rectangle_pts_face-anchor2).^2,2)); % which end of ROI is closest to anchor point
[min_dist2,min_idx2]=min(norm_dist2);

chest_dir=Rectangle_pts_face(min_idx,:)-Rectangle_pts_face(min_idx2,:);

chest_points=Rectangle_pts_face+chest_dir;
chest_points(chest_points<0)=1; % remove negatives
% Prevent error with clipping
chest_points_dim1=chest_points(:,2);
chest_points_dim1(chest_points_dim1>dim1)=dim1;
chest_points_dim2=chest_points(:,1);
chest_points_dim2(chest_points_dim2>dim2)=dim2;
chest_points(:,2)=chest_points_dim1;
chest_points(:,1)=chest_points_dim2;

%ROI_Chest=Face_ROI; % Assign chest ROI to face ROI and then change what is relevant
ROI_Chest(1)=min(chest_points(:,1));
ROI_Chest(2)=min(chest_points(:,2));
ROI_Chest(4)=chest_points(3,2)-chest_points(1,2);
ROI_Chest(3)=chest_points(4,1)-chest_points(1,1);
 % we define the new ROI by simply moving down our ROI in height 




end