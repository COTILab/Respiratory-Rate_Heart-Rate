%camera initialization--blackfly using matlab

%% FACE RECOGNITION DEMO
%% Written on 21OCT21-- Testing ROI recognition and tracking+speed
%% Will use FaceDetector to find BBOX every X number of Images and then use KLT to track points for Y Frames
%% Trying to support MULTIPLE ROIS
close all
clear all
clc

imaqreset % clear config and stops camera
%% flags
face_det_flag=1; % 1 if we use open CV to locate face, 0 if we want to manually choose ROI
MLSVD_FilterXY_Flag=0; % Filtering images in X and Y using MLSVD
% analysis flags
MLSVD_Analysis_Flag=0; % 1 if we are we analyzing using MLSVD
EMD_Analysis_Flag=1; %  1 if we are analyzing using EMD methods

%% Bounding box and Filter ranges
bp_mat{1}=[0.7 3.5];bp_mat{2}=[0.1 0.8]; % PER BOUNDING BOX
imf_mat{1}=[2 NaN];imf_mat{2}=[1 NaN]; % NaNs mean use the last component of IMF
num_ROIs=2; % How many ROIs are we analyzing

%% scaling factor,block size, point tracker, Face detector etc initialization
sf=1.1; % Lower =Higher chance of catching face BUT more computationally expensive+ higher false positives
num_pyr=4; % higher= better tracking but slower
bl_sz=51; % MUST BE ODD NUMBER
%% initializing trackers-- We have a chest KLT tracker if WE WANT to use it but it may not be necessary
pointTracker_IR = vision.PointTracker('BlockSize',[bl_sz bl_sz],'NumPyramidLevels',num_pyr);
pointTracker_Chest=vision.PointTracker('BlockSize',[bl_sz bl_sz],'NumPyramidLevels',num_pyr);
faceDetector_IR = vision.CascadeObjectDetector('ScaleFactor',sf(1)); % initializing
%% Parameters we fix for analysis
%fs_est=15; % what fs we want, frames per scond
%Analysis_Window_Length=7; % in seconds

%% other settings related to camera
exp_time=120;%66.6667;%(1/fs_est)*1000; % exposure time in ms
num_frames=200; % number of frames we take in a row before batch analysis
%% how many frames we use KLT to track
%KLT_frames=15; % We detect frame 1 using FaceDetector Cascade(Slow). then we use KLT for frames 2-KLT_frames+1
KLT_conf=0.8; % If we drop below this point, WE STOP using KLT Inceasing this value increases accuracy but slows down our analysis.
%
init_tc_frame_count=0;% how many frames will we throw away..  round(Init_tc/(1/fs_est));
%Analysis_frame_count=225;%round(Analysis_time/(1/fs_est));% converts time to frames as an estimate-- Rounds to whole number of frames
%Refresh_frame_count=25;% Analysis_frame_count;%round(Refresh_time/(1/fs_est)); % coverts time to frames as an estimate-- Rounds to whole number of frames
%time_d=0.1; % delay between images

%% INITIALIZING IR SOURCE IF STRUCTURE SENSOR
%% adding relevant paths
modpath='./Python Functions';
matlabfun_path='./Matlab Functions';
addpath(genpath(modpath));
addpath(genpath(matlabfun_path));
% reload python modules


%
%% Initialization-- Turns on video streams
dlib_key=imread('dlib_68pt_mapping_key.png'); % where the 68 landmark points SHOULD BE
VideoStreams=Camera_Initialization(modpath); % initialize
py.CameraFunctions.kill_both_streams(VideoStreams) % kill
pause(1)
VideoStreams=Camera_Initialization(modpath); % initialize
%% initializing Blackfly camera
tStart=tic;

%temp_cam_info       = imaqhwinfo('mwspinnakerimaq'); % Find info about system devices
%camList    = {temp_cam_info.DeviceInfo.DeviceName}; % Create list of available video devices
%camera.cam = videoinput('winvideo',1,char(temp_cam_info.DeviceInfo(1).SupportedFormats(9))); % 9 is RGB24_960x540,10 default for YUY2 720x1280--Internal Webcam asus
%camera.cam = videoinput('mwspinnakerimaq',1,char(temp_cam_info.DeviceInfo(1).SupportedFormats(3))); % 9 is RGB24_960x540,10 default for YUY2 720x1280--Internal Webcam asus
disp("Blackfly")


%camera.cam.FramesPerTrigger=1; % 1 frame per trigger
%camprop = getselectedsource(camera.cam);
disp("Set camera properties")
vid = videoinput('mwspinnakerimaq', 1, 'Mono16'); % mono16 image

src = getselectedsource(vid);

% preview(vid);
%
% stoppreview(vid);
%
src.ExposureTime = round(exp_time*1000);
%
% preview(vid);
%
% stoppreview(vid);
% closepreview

src.GainConversion = 'HCG'; % high conversion gain-- better for low light imaging
src.AdcBitDepth = 'Bit12'; % 12 bit ADC bit depth
vid.ROIPosition = [0 0 1936 1464]; % crop in matlab-- we always look at full image in matlab
%src.AcquisitionFrameCount=1;
%src.ExposureTime = round(exp_time*1000);

triggerconfig(vid, 'manual'); % manual trigger
vid.TriggerRepeat = Inf;
%% Taking specified images USING BLACKFLY
cam_init_flag=0; % initializ camera first

dim1=320; % currently fixed for camera
dim2=240; % currently fixed for camera
% plotting images from both sensors;


image_struct_first=BlackFly_TakeImgv2(vid,num_frames,cam_init_flag); % BLACKFLY

%% RESIZING IMAGE+ Transposes
orig=image_struct_first.images;
scale=1; % resize scale
temp=imresize(orig,scale);
%% END RESIZING IMAGE
image_struct_first.images=temp; % flip image

%image_struct_ST01=Take_Images_Fixedv2(VideoStreams,1,0,dim1,dim2);
cam_init_flag=1; % now it is initialized
%image_struct_first=BlackFly_TakeImg(vid,Analysis_frame_count+init_tc_frame_count);
%% For first image we test chase and face structure
tic
structure_img=uint8(image_struct_first.images/256); % 8 bit is faster to operate on
toc
DetectedFaceStruct{1}=FaceDetectionRefresh(structure_img(:,:,1),faceDetector_IR,pointTracker_IR);
DetectedChestStruct{1}=ChestDetectionRefresh(DetectedFaceStruct{1}.newBBox,structure_img(:,:,1),pointTracker_Chest,0);

%% plotting
nrows=3;
ncols=1;
figure;
plt1=subplot(nrows,ncols,1);
im1=imagesc(image_struct_first.images(:,:,1));colorbar
hold on
rectangle('Position',DetectedFaceStruct{1}.newBBox)
rectangle('Position',DetectedChestStruct{1}.Chest_BBox,'EdgeColor','r')
title("frame 1 + BBox Face+Chest")
hold off


%%
KLT_ctr=1; %
KLT_flag_arr=0; % We do not USE KLT on the first frame
key_targ=1;
time_vec(1)=DetectedFaceStruct{1}.time_taken;
conf_vec(1)=DetectedFaceStruct{1}.Bboxpoints_conf;
for i=2:size(structure_img,3)
    %taking image LIVE
    
    %image_struct=BlackFly_TakeImgv2(vid,1,cam_init_flag); % BLACKFLY
    %curr_img= uint8(image_struct.images/256); % already 8 bit and scaled
    curr_img=structure_img(:,:,i);
    if DetectedFaceStruct{i-1}.Bboxpoints_conf<KLT_conf % use cascade detectors to analyze if we have no confidence.
        KLT_flag_arr(i)=0; % Did not use KLT
        DetectedFaceStruct{i}=FaceDetectionRefresh(curr_img,faceDetector_IR,pointTracker_IR);
        DetectedChestStruct{i}=ChestDetectionRefresh(DetectedFaceStruct{i}.newBBox,curr_img,pointTracker_Chest,0);
        
        %KLT_ctr=1;
        %key_targ=i;
        if  length(DetectedFaceStruct{i}.newBBox)==0 % cant find face
            disp("No Face found. Continue to use KLT")
             KLT_flag_arr(i)=1; % Did use KLT
               DetectedFaceStruct{i}=KLT_Tracking(DetectedFaceStruct{i-1}.pointTracker,curr_img,...
            DetectedFaceStruct{key_targ}.newPoints,DetectedFaceStruct{key_targ}.newBBox);
        DetectedChestStruct{i}=ChestDetectionRefresh(DetectedFaceStruct{i}.newBBox,curr_img,pointTracker_Chest,0);
        
        
        else
            %KLT_ctr=1;
            key_targ=i;
        end
    else % Using KLT
        try
        KLT_flag_arr(i)=1; % Did  use KLT
        DetectedFaceStruct{i}=KLT_Tracking(DetectedFaceStruct{i-1}.pointTracker,curr_img,...
            DetectedFaceStruct{key_targ}.newPoints,DetectedFaceStruct{key_targ}.newBBox);
        DetectedChestStruct{i}=ChestDetectionRefresh(DetectedFaceStruct{i}.newBBox,curr_img,pointTracker_Chest,0);
        catch % if KLT fails, we use Cascade
             KLT_flag_arr(i)=0; % Did NOT use KLT
         DetectedFaceStruct{i}=FaceDetectionRefresh(curr_img,faceDetector_IR,pointTracker_IR);
        DetectedChestStruct{i}=ChestDetectionRefresh(DetectedFaceStruct{i}.newBBox,curr_img,pointTracker_Chest,0);
        key_targ=i;  
        disp("KLT Failed. Used cascade to find face due to inliers")
        end
        
    end
    
    KLT_ctr=KLT_ctr+1;
    
    
    %% plotting
    imagesc(plt1,image_struct_first.images(:,:,i));colorbar
    hold on
    rectangle('Position',DetectedFaceStruct{i}.newBBox,'LineWidth',4)
    rectangle('Position',DetectedChestStruct{i}.Chest_BBox,'EdgeColor','r','LineWidth',4)
    title(strcat("Frame-",num2str(i)));
    hold off
    drawnow
    pause(0.01);
    time_vec(i)=DetectedFaceStruct{i}.time_taken;
    conf_vec(i)=DetectedFaceStruct{i}.Bboxpoints_conf;
    %image_arr(:,:,i)=image_struct_fir.images;
end
subplot(nrows,ncols,2);
plot(time_vec);title("time to acq landmark vs frame ");
xlabel("frame num")
ylabel("time(seconds)")
total_time_taken=sum(time_vec);

subplot(nrows,ncols,3);
plot(conf_vec);title("Confidence vs frame ");
xlabel("frame num")
ylabel("time(seconds)")


%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% nrows=1;
% ncols=1;
% figure;
% ax1=subplot(nrows,ncols,1);im1=imagesc(image_struct_first.images(:,:,1));colorbar
% title("BlackFly")
% hold on
% %ax2=subplot(nrows,ncols,2);im2=imagesc(image_struct_ST01.images(:,:,1));colorbar
% %title("Structure Sensor Image")
% %hold on
% %[Cascade_outputs]=py.CameraFunctions.set_predictor_cascade; % preload classifiers to save time ONCE
% 
% if face_det_flag==1 % use facedetector
%     faceDetector = vision.CascadeObjectDetector('ScaleFactor',1.1); % initializing
%     img_ctr=1;
%     while(1)
%         
%         
%         if exist('landmarks')&&exist('rectangles')
%             
%             delete(landmarks)
%             delete(rectangles)
%             %clear(landmarks)
%             %clear(rectangles)
%             clear rectangles landmarks
%             
%         end
%         image_struct_first=BlackFly_TakeImgv2(vid,1,cam_init_flag); % BLACKFLY
%         % Transposing and flipping
%         orig=image_struct_first.images;
%         temp=imresize(orig,scale);
%         image_struct_first.images=temp; %
%         
%         %% Matlab computer vision toolbox
%         if img_ctr==1
%             BBox_bf=step(faceDetector,image_struct_first.images);
%             points = detectMinEigenFeatures(image_struct_first.images, 'ROI',BBox_bf);  % Landmarks to follow
%             visiblePoints=points;
%             %% USE KLT TO TRACK
%             pointTracker = vision.PointTracker('BlockSize',[51 51],'NumPyramidLevels',4);
%             
%             % Initialize the tracker with the initial point locations and the initial
%             % video frame.
%             points = points.Location;
%             initialize(pointTracker, points, image_struct_first.images);
%             bboxPoints = bbox2points(BBox_bf(1, :));
%             
%             BBox_bf2=[min(bboxPoints(:,1)), min(bboxPoints(:,2)),max(bboxPoints(:,1))-min(bboxPoints(:,1)),max(bboxPoints(:,2))-min(bboxPoints(:,2))],
%             
%         end
%         oldPoints=points; % old points
%         
%         
%         
%         if img_ctr==0  % not the first frame
%             [points, isFound] = step(pointTracker, image_struct_first.images);
%             visiblePoints = points(isFound, :);
%             oldInliers = oldPoints(isFound, :);
%             
%             
%             % Estimate the geometric transformation between the old points
%             % and the new points and eliminate outliers
%             
%             if size(visiblePoints, 1) >= 2 % need at least 2 points
%                 [xform, inlierIdx] = estimateGeometricTransform2D(...
%                     oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
%                 oldInliers    = oldInliers(inlierIdx, :);
%                 visiblePoints = visiblePoints(inlierIdx, :);
%                 
%                 % Apply the transformation to the bounding box points
%                 bboxPoints = transformPointsForward(xform, bboxPoints);
%                 
%                 % Insert a bounding box around the object being tracked
%                 bboxPolygon = reshape(bboxPoints', 1, []);
%                 BBox_bf2=[min(bboxPoints(:,1)), min(bboxPoints(:,2)),max(bboxPoints(:,1))-min(bboxPoints(:,1)),max(bboxPoints(:,2))-min(bboxPoints(:,2))];
%                 
%                 
%                 % Reset the points
%                 oldPoints = visiblePoints;
%                 setPoints(pointTracker, oldPoints);
%                 
%                 
%             end
%             
%             
%         end
%         
%         
%         
%         % plot
%         %set(im1,'CData',image_struct_first.images)
%         imagesc(image_struct_first.images);colorbar;hold on
%         if size(BBox_bf,1)==1
%             %rectangles=rectangle(ax1,'Position',BBox_bf2); % Face
%             rectangle(ax1,'Position',BBox_bf2,'LineWidth',4);
%             if img_ctr==1
%                 %landmarks=scatter(ax1,visiblePoints.Location(:,1),visiblePoints.Location(:,2),'ro'); % landmarks
%                 scatter(visiblePoints.Location(:,1),visiblePoints.Location(:,2),'ro'); % landmarks
%             end
%             
%             if img_ctr==0
%                 %landmarks=scatter(ax1,visiblePoints(:,1),visiblePoints(:,2),'ro'); % landmarks
%                 scatter(visiblePoints(:,1),visiblePoints(:,2),'ro'); % landmarks
%             end
%             
%             drawnow
%             
%             
%         end
%         
%         
%         
%         
%         %        end
%         pause(0.1);
%         img_ctr=0;
%     end
%     
%     
% end
