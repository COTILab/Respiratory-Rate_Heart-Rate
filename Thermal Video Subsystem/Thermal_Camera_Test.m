clear all
clear Take_Thermal_Camera_Images
clc
close all
%instrreset
imaqreset;disp("IMAQRESET");imaqreset;disp("IMAQRESET")
%%

%
addpath(genpath('./Thermal_VZ_Functions'))
addpath(genpath('../NIR Video Subsystem'));
%% scaling factor,block size, point tracker, Face detector etc initialization
Refresh_ROI_Frames=1;% How many frames do we want to recalculate the ROI
sf=1.04; % Lower =Higher chance of catching face BUT more computationally expensive+ higher false positives
num_pyr=4; % higher= better tracking but slower
bl_sz=51; % MUST BE ODD NUMBER
KLT_conf=0.8; % what value we drop below before we use cascade detector, Higher value=more accurate but slower
%% initializing trackers-- We have a chest KLT tracker if WE WANT to use it but it may not be necessary
pointTracker_Face = vision.PointTracker('BlockSize',[bl_sz bl_sz],'NumPyramidLevels',num_pyr);
pointTracker_Chest=vision.PointTracker('BlockSize',[bl_sz bl_sz],'NumPyramidLevels',num_pyr);
faceDetector = vision.CascadeObjectDetector('ScaleFactor',sf(1)); % initializing


%% Parameters
num_frames=20;
vis_flag=1; % 1 means visualize everything
[image_struct]=Take_Thermal_Camera_Images(num_frames);
figure;imshow(image_struct.images(:,:,:,end))
figure;imagesc(im2gray(image_struct.images(:,:,:,end)))
%% can we find face?
[DetectedFaceStruct,~,detail_struct]=GetFaceandChestROI(image_struct,faceDetector,pointTracker_Face,pointTracker_Chest,KLT_conf,Refresh_ROI_Frames);
idx=1;%length(DetectedFaceStruct);
figure;imshow(image_struct.images(:,:,:,idx))
hold on
rectangle('Position',DetectedFaceStruct{idx}.newBBox,'EdgeColor','r')
