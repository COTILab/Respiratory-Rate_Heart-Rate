function DetectedFaceStruct=FaceDetectionRefresh(images,FaceDetector,PointTracker)
tStart=tic;

%% CASCADE DETECTOR
%% written on 19OCT21
%MATLAB BASED:
%Uses Face Detector to find LARGEST FACE(works for 1 face in frame)
% Slower than point tracker but helps to REFRESH Landmarks COMPLETELY as
% POINT TRACKER GRADUALLY FAILS
BBox=step(FaceDetector,images); % Find Faces
Area=0;
Face_BBox=[];
minArea=6000; % cut out aberrationss
for i=1:size(BBox,1) % every face found
    temp=BBox(i,3)*BBox(i,4); %Area of BBox
    if temp>Area&&temp>minArea
        Area=temp;
        Face_BBox=BBox(i,:); % Get largest Face
    end
    
end
% Adding Struct output
DetectedFaceStruct.newBBox=Face_BBox;
%% adding MinimumEigenPoints to track
DetectedFaceStruct.newPoints=detectMinEigenFeatures(images, 'ROI', Face_BBox);
DetectedFaceStruct.newPoints=DetectedFaceStruct.newPoints.Location; % Getting locations from CornerObject...
%% Return Pointracker object AFTER initializing it

try 
release(PointTracker)
disp("Initialized New point tracker to track")
catch
end
try
initialize(PointTracker,DetectedFaceStruct.newPoints,images);
catch
disp("FAILED")

end
DetectedFaceStruct.pointTracker=PointTracker;
% Get Point Confidence-- Basically HOW GOOD IS OUR FIT
BBoxpoints=bbox2points(DetectedFaceStruct.newBBox); % query points
BBoxpoints_conf= inpolygon(DetectedFaceStruct.newPoints(:,1),DetectedFaceStruct.newPoints(:,2),BBoxpoints(:,1),BBoxpoints(:,2));
DetectedFaceStruct.Bboxpoints_conf=nnz(BBoxpoints_conf)/size(DetectedFaceStruct.newPoints,1);

%% Time Taken
DetectedFaceStruct.UsedCascade=1; % flag so we know we used cascade detector
DetectedFaceStruct.time_taken=toc(tStart); % time in seconds
end