%% Webcam KLT Tracking
close all
clear all
clc
%%
take_img=0; % take new
num_frames=75;
%%

addpath(genpath('./Saved Data Debugging'))
addpath(genpath('./Matlab Functions'))
if take_img==1
    disp("TAKING NEW IMAGES")
    cam=webcam;
    for i=1:num_frames
        rgbImage=snapshot(cam);
        grayImage(:,:,i) = rgb2gray(rgbImage);
    end
    % prviewiing AFTER to save time on acuiriing images
    figure;
    im1=imagesc(grayImage(:,:,1));
    for i=1:num_frames
        set(im1,'CData',grayImage(:,:,i));
        drawnow
        pause(0.01);
        title(i);
    end
    webcam_img=grayImage;
    
else
   % webcam_img=importdata('Webcam_img.mat'); % Prerecorded data
   %webcam_img=importdata('Webcam_img.mat');
  webcam_img=importdata('Blackfly_Color_img.mat');disp('BlackFlyColor')
  webcam_img=uint8(webcam_img.images/256);
   
end
%% Loading structure sensor data
structure_img=importdata('StructureSensor_IR.mat');
%structure_img=importdata('Blackfly_Color_img.mat');disp('BlackFlyColor')
structure_img=uint8(structure_img.images/256);
disp("RESCALING IMAGE FOR TESTING")
scale=1;
for i=1:size(structure_img,3)
   new_img(:,:,i)=imresize(structure_img(:,:,i),scale);
end
structure_img=new_img;
%% Factors for face tracker
sf=[1.1 1.1]; % scaling factor- IR then color
bl_sz=51;  % has to be odd -- Block size for gradient. Larger = More accurate+ more expensive
num_pyr=4; % number of pyramids for point tracking--> Larger(max of 4 recommended)= more accurate+more expensive
% initialization
pointTracker_IR = vision.PointTracker('BlockSize',[bl_sz bl_sz],'NumPyramidLevels',num_pyr);
faceDetector_IR = vision.CascadeObjectDetector('ScaleFactor',sf(1)); % initializing

pointTracker_color = vision.PointTracker('BlockSize',[bl_sz bl_sz],'NumPyramidLevels',num_pyr);
faceDetector_color = vision.CascadeObjectDetector('ScaleFactor',sf(2)); % initializing

%% Initial Bounding Box % find settings that detect 1 ROI per image
tic
BBox_IR_init=step(faceDetector_IR,structure_img(:,:,1)); % initial bounding box for IR sT01
toc

tic
BBox_webcam_init=step(faceDetector_color,webcam_img(:,:,1)); % initial bounding box for webcam
toc
%% Initial Landmarks
tic
points_IR = detectMinEigenFeatures(structure_img(:,:,1), 'ROI', BBox_IR_init);  % Landmarks to follow
visiblePoints_IR=points_IR;
toc
% color

points_color = detectMinEigenFeatures(webcam_img(:,:,1), 'ROI', BBox_webcam_init);  % Landmarks to follow
visiblePoints_color=points_color;


%% initial figure and visualization
figure
nrows=2;
ncols=1;
ax1=subplot(nrows,ncols,1);im1=imagesc(structure_img(:,:,1));colorbar;
title('IR');hold on;rectangle_IR=rectangle('Position',BBox_IR_init);
landmarks_plot_IR=scatter(ax1,visiblePoints_IR.Location(:,1),visiblePoints_IR.Location(:,2),1,'r');

ax2=subplot(nrows,ncols,2);im2=imagesc(webcam_img(:,:,1));colorbar;
title('Webcam Grayscale Visible');hold on;rectangle_color=rectangle('Position',BBox_webcam_init);
landmarks_plot_color=scatter(ax2,visiblePoints_color.Location(:,1),visiblePoints_color.Location(:,2),1,'r');

%% begin tracking

points_IR=points_IR.Location;
points_color=points_color.Location;
oldPoints_IR=points_IR;
oldPoints_color=points_color;
initialize(pointTracker_IR, points_IR, structure_img(:,:,1));
initialize(pointTracker_color,points_color, webcam_img(:,:,1));
% converting bbox to points
bboxPoints_IR = bbox2points(BBox_IR_init(1, :));
bboxPoints_color = bbox2points(BBox_webcam_init(1, :));

% spanning rest of images-- Use KLT to track
for i=2:size(webcam_img,3) % assuming webcam and IR images have same number of frames
    %% getting rid of old fields
    delete(rectangle_IR)
    delete(landmarks_plot_IR)
    
    delete(rectangle_color)
    delete(landmarks_plot_color)
    
    
   
    
    new_IR_img= structure_img(:,:,i); % load new img
    new_color_img= webcam_img(:,:,i); % load new img
    
    %% IR First
    tic
    [points_IR, isFound_IR] = step(pointTracker_IR, new_IR_img);
    %% Dow
    visiblePoints_IR = points_IR(isFound_IR, :);
    oldInliers_IR = oldPoints_IR(isFound_IR, :);
    
    %% IR 
    
    if size(visiblePoints_IR, 1) >= 2 % need at least 2 points
        [xform_IR, inlierIdx_IR] = estimateGeometricTransform2D(...
            oldInliers_IR, visiblePoints_IR, 'similarity', 'MaxDistance', 100);
        oldInliers_IR    = oldInliers_IR(inlierIdx_IR, :);
        visiblePoints_IR = visiblePoints_IR(inlierIdx_IR, :);
        
        % Apply the transformation to the bounding box points
        bboxPoints_IR = transformPointsForward(xform_IR, bboxPoints_IR);
        
        % Insert a bounding box around the object being tracked
        bboxPolygon_IR = reshape(bboxPoints_IR', 1, []);
        BBox_IR=[min(bboxPoints_IR(:,1)), min(bboxPoints_IR(:,2)),max(bboxPoints_IR(:,1))-min(bboxPoints_IR(:,1)),max(bboxPoints_IR(:,2))-min(bboxPoints_IR(:,2))];
        
        
        % Reset the points
        oldPoints_IR = visiblePoints_IR;
        setPoints(pointTracker_IR, oldPoints_IR);
        
        
    end
    %% Color 
      [points_color, isFound_color] = step(pointTracker_color, new_color_img);
    visiblePoints_color = points_color(isFound_color, :);
    oldInliers_color = oldPoints_color(isFound_color, :);
    
    %% IR 
    
    if size(visiblePoints_color, 1) >= 2 % need at least 2 points
        [xform_color, inlierIdx_color] = estimateGeometricTransform2D(...
            oldInliers_color, visiblePoints_color, 'similarity', 'MaxDistance', 100);
        oldInliers_color    = oldInliers_color(inlierIdx_color, :);
        visiblePoints_color = visiblePoints_color(inlierIdx_color, :);
        
        % Apply the transformation to the bounding box points
        bboxPoints_color = transformPointsForward(xform_color, bboxPoints_color);
        
        % Insert a bounding box around the object being tracked
        bboxPolygon_color = reshape(bboxPoints_color', 1, []);
        BBox_color=[min(bboxPoints_color(:,1)), min(bboxPoints_color(:,2)),max(bboxPoints_color(:,1))-min(bboxPoints_color(:,1)),max(bboxPoints_color(:,2))-min(bboxPoints_color(:,2))];
        
        
        % Reset the points
        oldPoints_color = visiblePoints_color;
        setPoints(pointTracker_color, oldPoints_color);
        
        
    end

%% plotting updated images
%IR
set(im1,'CData', new_IR_img);title(ax1,strcat("Blackfly+IRSensor-Frame:",num2str(i))); % Update image
rectangle_IR=rectangle(ax1,'Position',BBox_IR,'EdgeColor','m','LineWidth',5);
landmarks_plot_IR=scatter(ax1,visiblePoints_IR(:,1),visiblePoints_IR(:,2),1,'r');
    

set(im2,'CData', new_color_img);title(ax2,strcat("Webcam-Frame:",num2str(i))); % Update image
rectangle_color=rectangle(ax2,'Position',BBox_color,'EdgeColor','m','LineWidth',5);
landmarks_plot_color=scatter(ax2,visiblePoints_color(:,1),visiblePoints_color(:,2),1,'r');
    

%delete(rectangle_color)
 %   delete(landmarks_plot_color)
    
    
    
pause(0.04)








end
%%
%%
%% Testing Functions written
pointTracker_IR = vision.PointTracker('BlockSize',[bl_sz bl_sz],'NumPyramidLevels',num_pyr);
pointTracker_Chest=vision.PointTracker('BlockSize',[bl_sz bl_sz],'NumPyramidLevels',num_pyr);
faceDetector_IR = vision.CascadeObjectDetector('ScaleFactor',sf(1)); % initializing
% initial face and struct
DetectedFaceStruct=FaceDetectionRefresh(structure_img(:,:,1),faceDetector_IR,pointTracker_IR);
DetectedChestStruct=ChestDetectionRefresh(DetectedFaceStruct.Face_BBox,structure_img(:,:,1),pointTracker_Chest);
%% KLT Tracking
figure
for i=2:size(structure_img,3) % for every image
    %if i==2
 KLT_out_struct(i-1)=KLT_Tracking(DetectedFaceStruct.PointTracker,structure_img(:,:,i),...
     DetectedFaceStruct.LandmarkPoints,DetectedFaceStruct.Face_BBox);
 %% using KLT with Chest as well
 KLT_out_struct_chest(i-1)=KLT_Tracking(DetectedChestStruct.PointTracker,structure_img(:,:,i),...
    DetectedChestStruct.LandmarkPoints,DetectedChestStruct.Chest_BBox);
    %end
    
    
    ShiftedChestStruct(i-1)=ChestDetectionRefresh(KLT_out_struct(i-1).newBBox,structure_img(:,:,1),pointTracker_Chest);
% i
imagesc(structure_img(:,:,i));colorbar;title(i);
hold on
rectangle('Position',KLT_out_struct(i-1).newBBox);
rectangle('Position',KLT_out_struct_chest(i-1).newBBox);
rectangle('Position',ShiftedChestStruct(i-1).Chest_BBox,'EdgeColor','r');
drawnow
hold off
pause(0.01)
timings(i)=KLT_out_struct(i-1).time_taken;
end
timings(1)=DetectedFaceStruct.time_taken;
KLT_timings=mean(timings(2:end));
figure;plot(timings);xlabel("Image #");ylabel("time(seconds)");
