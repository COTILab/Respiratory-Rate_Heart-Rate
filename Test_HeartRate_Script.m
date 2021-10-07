% Relevant Sources:
% 1: https://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=8375962&tag=1
%2: KLT Alg: https://www.mathworks.com/help/vision/ug/face-detection-and-tracking-using-the-klt-algorithm.html
% 3: https://www.youtube.com/watch?v=2LVeCrHqyqs-- IMF Explanation :13
% minutes and onwards
%%
close all
clear all
clc
%% add path
addpath(genpath('./Test Input Videos/')); % add path of video
addpath(genpath('./Additional Functions/')); % add custom Functions RR
%% this proces is ripped straight from (2)
% Create a cascade detector object.
faceDetector = vision.CascadeObjectDetector();
% Read a video frame and run the face detector.
videoReader = VideoReader('face2.mp4');
videoFrame      = readFrame(videoReader);
bbox            = step(faceDetector, videoFrame);

% Draw the returned bounding box around the detected face.
videoFrame = insertShape(videoFrame, 'Rectangle', bbox);
figure; imshow(videoFrame); title('Detected face');
% Convert the first box into a list of 4 points
% This is needed to be able to visualize the rotation of the object.
bboxPoints = bbox2points(bbox(1, :)); % i dont know if this can do multiple faces

points = detectMinEigenFeatures(rgb2gray(videoFrame), 'ROI', bbox);

% Display the detected points.
figure, imshow(videoFrame), hold on, title('Detected features');
plot(points);

% initialize point tracker
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);

%% point grid of frame
height=1:1:size(videoFrame,1);
width=1:1:size(videoFrame,2);
[xx,yy]=meshgrid(height,width);

% Initialize the tracker with the initial point locations and the initial
% video frame.
%test=inpolygon(xx(:),yy(:),bboxPoints(:,1),bboxPoints(:,2));
%test_rs=reshape(test,size(xx));

%% selecting sub region of ROI based off specifications here
height_perc=0.1;% height bounds
width_perc=0.1;% Width bounds
newBox=Subregion_Selection(bboxPoints,height_perc,width_perc);
%%
reshaped_pts_in_rect=Points_In_Rectangle(xx,yy,newBox(:,1),newBox(:,2));
% for first frame
red_pix=videoFrame(:,:,1);
green_pix=videoFrame(:,:,2);
blue_pix=videoFrame(:,:,3);
RGB_sel_pixels(1,1).sel_pix=red_pix(reshaped_pts_in_rect); % red pixels  in bounding box
RGB_sel_pixels(1,2).sel_pix=green_pix(reshaped_pts_in_rect); % green pixels in bounding box
RGB_sel_pixels(1,3).sel_pix=blue_pix(reshaped_pts_in_rect); % blue pixels in bounding box

RGB_sel_pixels(1,1).avg_sel_pix=(mean(RGB_sel_pixels(1,1).sel_pix)); % average of red channel over Bounding box (ROI)
RGB_sel_pixels(1,2).avg_sel_pix=(mean(RGB_sel_pixels(1,2).sel_pix)); % average of red channel over Bounding box (ROI)
RGB_sel_pixels(1,3).avg_sel_pix=(mean(RGB_sel_pixels(1,3).sel_pix)); % average of red channel over Bounding box (ROI)
% first frame
%% landmark points.. proably not needed
points = points.Location;
initialize(pointTracker, points, videoFrame);
%
oldPoints = points;

videoPlayer  = vision.VideoPlayer('Position',...
    [100 100 [size(videoFrame, 2), size(videoFrame, 1)]+30]);

frame_ctr=2; % frame ctr
while hasFrame(videoReader)
    % get the next frame
    videoFrame = readFrame(videoReader);
    
    % Track the points. Note that some points may be lost.
    [points, isFound] = step(pointTracker, videoFrame);
    visiblePoints = points(isFound, :);
    oldInliers = oldPoints(isFound, :);
    
    if size(visiblePoints, 1) >= 2 % need at least 2 points
        
        % Estimate the geometric transformation between the old points
        % and the new points and eliminate outliers
        [xform, inlierIdx] = estimateGeometricTransform2D(...
            oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
        oldInliers    = oldInliers(inlierIdx, :);
        visiblePoints = visiblePoints(inlierIdx, :);
        
        % Apply the transformation to the bounding box points
        bboxPoints(:,:,frame_ctr) = transformPointsForward(xform, bboxPoints(:,:,frame_ctr-1));
        temp= bboxPoints(:,:,frame_ctr);
        % Insert a bounding box around the object being tracked
        bboxPolygon(:,:,frame_ctr) = reshape(temp', 1, []);
        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon(:,:,frame_ctr), ...
            'LineWidth', 2);
        
        % Display tracked points
        % videoFrame = insertMarker(videoFrame, visiblePoints, '+', ...
        %    'Color', 'white');
        
        % Reset the points
        oldPoints = visiblePoints;
        setPoints(pointTracker, oldPoints);
        %% getting new pixels that are WITHIN ROI-- Added by RR
        newBox(:,:,frame_ctr)=Subregion_Selection(bboxPoints(:,:,frame_ctr),height_perc,width_perc);
        temp2=newBox(:,:,frame_ctr);
        reshaped_pts_in_rect(:,:,frame_ctr)=Points_In_Rectangle(xx,yy,temp2(:,1),temp2(:,1));
        % For each of RGB Channel, we extract the relevant pixels
        red_pix=videoFrame(:,:,1);
        green_pix=videoFrame(:,:,2);
        blue_pix=videoFrame(:,:,3);
        
        RGB_sel_pixels(frame_ctr,1).sel_pix=red_pix(reshaped_pts_in_rect(:,:,frame_ctr)); % red pixels  in bounding box
        RGB_sel_pixels(frame_ctr,2).sel_pix=green_pix(reshaped_pts_in_rect(:,:,frame_ctr)); % green pixels in bounding box
        RGB_sel_pixels(frame_ctr,3).sel_pix=blue_pix(reshaped_pts_in_rect(:,:,frame_ctr)); % blue pixels in bounding box
        
        RGB_sel_pixels(frame_ctr,1).avg_sel_pix=(mean(RGB_sel_pixels(frame_ctr,1).sel_pix)); % average of red channel over Bounding box (ROI)
        RGB_sel_pixels(frame_ctr,2).avg_sel_pix=(mean(RGB_sel_pixels(frame_ctr,2).sel_pix)); % average of red channel over Bounding box (ROI)
        RGB_sel_pixels(frame_ctr,3).avg_sel_pix=(mean(RGB_sel_pixels(frame_ctr,3).sel_pix)); % average of red channel over Bounding box (ROI)
        %
        
    end
    
    % Display the annotated video frame using the video player object
    step(videoPlayer, videoFrame);
    
    frame_ctr=frame_ctr+1; % incrementing frame--> This will end up being 1 larger than the overall number of frames in the entire video
    
end
% extracting frame rate and frame timers based on number of frames in video
% + frame rate

% Clean up
release(videoPlayer);

%% Right now this is all post processing... we can update it later to take "chunks" of the video to see if we can take LIVE HR measurements
frame_ctr=frame_ctr-1; % correcting for incrementing
samp_rate=1/videoReader.FrameRate;
frame_times=0:samp_rate:samp_rate*frame_ctr-samp_rate;
%% initial raw data -- all 3 channels
% putting in simple vector
for i=1:size(RGB_sel_pixels,1)
    red_raw_data(i)=RGB_sel_pixels(i,1).avg_sel_pix;
    green_raw_data(i)=RGB_sel_pixels(i,2).avg_sel_pix;
    blue_raw_data(i)=RGB_sel_pixels(i,3).avg_sel_pix;
    
end


figure
nrows=1; % 
ncols=3; % channels

subplot(nrows,ncols,1);plot(frame_times,red_raw_data);title("red Channel");xlabel('time(s)'); ylabel("Bounding Box average")

subplot(nrows,ncols,2);plot(frame_times,green_raw_data);title("green Channel");xlabel('time(s)'); ylabel("Bounding Box average")

subplot(nrows,ncols,3);plot(frame_times,blue_raw_data);title("blue Channel");xlabel('time(s)'); ylabel("Bounding Box average")

sgtitle("All Channels--Raw Data")
%% Run Empiric Mode Decomposition (EMD) See (3) and (1) for explanation . Iterative procedure
% matlab has the necessary functions to run EMD already present --> https://www.mathworks.com/help/signal/ref/emd.html#mw_4b56fb68-1585-470b-a71f-799e14a85cad
% we must identify the valid terminaton criterion however..
[imf_red,residual_red,info_red] = emd(red_raw_data);
[imf_green,residual_green,info_green] = emd(green_raw_data);
[imf_blue,residual_blue,info_blue] = emd(blue_raw_data);

%% reconstruction of IMF --> Signal 



