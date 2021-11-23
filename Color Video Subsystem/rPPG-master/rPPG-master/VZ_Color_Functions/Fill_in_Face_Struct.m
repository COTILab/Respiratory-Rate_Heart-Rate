function DetectedFaceStruct=Fill_in_Face_Struct(DetectedFaceStruct)
%% Written on 22NOV21
%% Goal: Fill in Detected Face Structure so we can use any of the methods such as K-means to select pixels. in Default RunMeScrpt, we want to match the SkinDetection Struct in terms of the fields we use. See below

%% Structs we need to fill in
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DetectedFaceStruct.nFaceSectors=12; 
% DetectedFaceStruct.method=2;
% DetectedFaceStruct.nColorClusters=4; 
% DetectedFaceStruct.calcFrameRate=0;
% DetectedFaceStruct.fracPixelsPresent = 0.8;      % [0-1]; fraction of colored pixels within a face grid sector that needs to be detected as skin color
%% x = faceDetection.bbox(1, 1); 
%% y = faceDetection.bbox(1, 2); 
%% w = faceDetection.bbox(1, 3); 
%% h = faceDetection.bbox(1, 4);
% faceDetection.bboxPolygon = [x, y, x+w, y, x+w, y+h, x, y+h];

%% NOTE THESE ARE INCOMPLETE. HAVE TO LOOK TO SEE WHAT THESE MEAN
%DetectedFaceStruct.firstTimeDetected=1;
%DetectedFaceStruct.nTimesDetected=1;
%% Needed for k means
%DetectedFaceStruct.f=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
for i=1:length(DetectedFaceStruct)
  DetectedFaceStruct{i}.nFaceSectors=12; 
  DetectedFaceStruct{i}.method=2;
  DetectedFaceStruct{i}.nColorClusters=4; 
  DetectedFaceStruct{i}.calcFrameRate=0;
  DetectedFaceStruct{i}.fracPixelsPresent = 0.8; 
  % BBox Polygon
  x=DetectedFaceStruct{i}.newBBox(1);
  y=DetectedFaceStruct{i}.newBBox(2);
  w=DetectedFaceStruct{i}.newBBox(3);
  h=DetectedFaceStruct{i}.newBBox(1);
  % 
  DetectedFaceStruct{i}.bboxPolygon = [x, y, x+w, y, x+w, y+h, x, y+h];
  %% NOTE THESE 2 MAY BE INCORRECT BUT ARE NOT USED FOR KMEANS
DetectedFaceStruct{i}.firstTimeDetected=1;
DetectedFaceStruct{i}.nTimesDetected=1;
DetectedFaceStruct{i}.f=1;   
    
    
    
end
end