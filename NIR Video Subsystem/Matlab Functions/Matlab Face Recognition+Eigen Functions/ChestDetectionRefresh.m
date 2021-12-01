function DetectedChestStruct=ChestDetectionRefresh(FaceBBox,images,PointTracker,varargin)
tStart=tic;
%% written on 20OCT21
%MATLAB BASED:
%Uses Face Detector to find LARGEST FACE(works for 1 face in frame)
% Slower than point tracker but helps to REFRESH Landmarks COMPLETELY as
% POINT TRACKER GRADUALLY FAILS

%% SET Varargin{1} to 0 if we simply want to SHIFT the BBox based on the face to save time significantly
if length(varargin)>0
    landmark_flag=varargin{1};
else
    landmark_flag=1; % by default we find landmarks
end

FaceBBoxpoints=bbox2points(FaceBBox);
New_BBox=FaceBBox;
New_BBox(2)=max(FaceBBoxpoints(:,2))+100; % shifting box down, Random Shifting Element

if New_BBox(2)+New_BBox(4)>size(images,1)
    temp=size(images,1)-New_BBox(2);
    New_BBox(4)=temp; % prevent clipping
end
% Adding Struct output
DetectedChestStruct.Chest_BBox=New_BBox;
%% adding MinimumEigenPoints to track
if landmark_flag==1
    DetectedChestStruct.LandmarkPoints=detectMinEigenFeatures(images, 'ROI', New_BBox);
    DetectedChestStruct.LandmarkPoints=DetectedChestStruct.LandmarkPoints.Location; % Getting locations from CornerObject...
    %% Return Pointracker object AFTER initializing it
    DetectedChestStruct.PointTracker=PointTracker;
    try
        initialize(PointTracker,DetectedChestStruct.LandmarkPoints,images);
    catch
    end
end
%% Time Taken

DetectedChestStruct.time_taken=toc(tStart); % time in seconds
end