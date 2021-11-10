function [DetectedFaceStruct,DetectedChestStruct,detail_struct]=GetFaceandChestROI(image_struct,faceDetector_IR,pointTracker_Face,pointTracker_Chest,KLT_conf,Refresh_ROI_Frames,varargin)
%% Written on 25OCT21; Returns struct or face and chest ROIs from stack of images; Use Cascade Detector when necessary but otherwise uses KLT algorithm for faster tracking
%1. image_struct: Stack of images
%2 faceDetector_IR; Face Detector Cascade Detector
%3.pointTracker_IR: KLT Point Tracker
%4. KLT_conf: Value that sets when we use KLT vs Cascade Filter. Confidence
%less than KLT_conf makes it so we use Cascade Detector 
%5. Refresh_ROI_Frames: Increment between frames we want to even check
t_s=tic;
 bit_8_img=uint8(image_struct.images/256); % converting to 8 bit as it is faster to analyze
 %% For First image use Cascade Detector 
 for i=1:size(bit_8_img,3) % THIS WILL ONLY FAIL IF EVERY SINGLE IMAGE CANT BE ANALYZED WITH CASCADE
     try
 DetectedFaceStruct{1}=FaceDetectionRefresh(bit_8_img(:,:,i),faceDetector_IR,pointTracker_Face);
     catch
         disp("Could not find face")
 DetectedFaceStruct{1}.newBBox=[];
     end
    % Chest detector currently is a simple shift based on face ROI
 
 if size(DetectedFaceStruct{1}.newBBox,2)==4 % Finds 1 face. Multiple faces case already handled
     DetectedChestStruct{1}=ChestDetectionRefresh(DetectedFaceStruct{1}.newBBox, bit_8_img(:,:,i),pointTracker_Chest,0);
     detail_struct.init_img_casc=i; % which image did we initially find using bascade
     break;% If we find a face we break out
     
 end
 end
     %% For subsequent frames  
KLT_flag_arr=0; % We do not USE KLT on the first frame
key_targ=1; % Last frame where we use cascade detector- My default this is 1 as we use cascade detector initially
time_vec(1)=DetectedFaceStruct{1}.time_taken;
conf_vec(1)=DetectedFaceStruct{1}.Bboxpoints_conf;
ctr=2;

 for i=Refresh_ROI_Frames+1:Refresh_ROI_Frames:size(bit_8_img,3)
        curr_img=bit_8_img(:,:,i);
        if DetectedFaceStruct{i-Refresh_ROI_Frames}.Bboxpoints_conf<KLT_conf % fall below confidence limit, Therefore use cascade detector
            KLT_flag_arr(ctr)=0; % Did not use KLT
            DetectedFaceStruct{i}=FaceDetectionRefresh(curr_img,faceDetector_IR,pointTracker_Face);
            DetectedChestStruct{i}=ChestDetectionRefresh(DetectedFaceStruct{i}.newBBox,curr_img,pointTracker_Chest,0);
            
            
            if  length(DetectedFaceStruct{i}.newBBox)==0 % cant find face
                disp("No Face found. Continue to use KLT")
                KLT_flag_arr(ctr)=1; % Did use KLT
                DetectedFaceStruct{i}=KLT_Tracking(DetectedFaceStruct{i-1}.pointTracker,curr_img,...
                    DetectedFaceStruct{key_targ}.newPoints,DetectedFaceStruct{key_targ}.newBBox);
                DetectedChestStruct{i}=ChestDetectionRefresh(DetectedFaceStruct{i}.newBBox,curr_img,pointTracker_Chest,0);
                
                
            else
                %KLT_ctr=1;
                key_targ=i; % use this for KLT moving forward
            end
            %KLT_ctr=1;
            
        else %% USING KLT NOW as we are ABOVE CONFIDENCE-- KLT=FAST Tracking
            try
                KLT_flag_arr(ctr)=1; % Did  use KLT
                DetectedFaceStruct{i}=KLT_Tracking(DetectedFaceStruct{i-Refresh_ROI_Frames}.pointTracker,curr_img,...
                    DetectedFaceStruct{key_targ}.newPoints,DetectedFaceStruct{key_targ}.newBBox);
                DetectedChestStruct{i}=ChestDetectionRefresh(DetectedFaceStruct{i}.newBBox,curr_img,pointTracker_Chest,0);
            catch % if KLT fails, we use Cascade
                KLT_flag_arr(ctr)=0; % Did NOT use KLT
                DetectedFaceStruct{i}=FaceDetectionRefresh(curr_img,faceDetector_IR,pointTracker_Face);
                DetectedChestStruct{i}=ChestDetectionRefresh(DetectedFaceStruct{i}.newBBox,curr_img,pointTracker_Chest,0);
                key_targ=i;
                disp("KLT Failed. Used cascade to find face due to inliers")
            end
            
        end
        conf_vec(ctr)=DetectedFaceStruct{i}.Bboxpoints_conf;
        time_vec(ctr)=DetectedFaceStruct{i}.time_taken;
        ctr=ctr+1;
    end
    
    
    %% Filling in empty entries of struct based on how frequently we found ROI-- Basically assigning ROI to frames we DID not analyze
    DetectedFaceStruct=Fill_Empty_Struct(bit_8_img,DetectedFaceStruct); 
    DetectedChestStruct=Fill_Empty_Struct(bit_8_img,DetectedChestStruct); 
   %% Detail_Structure details: useful for debugging and does not use too mcuh memory
    
    detail_struct.time_vec=time_vec;
    detail_struct.KLT_flag_arr=KLT_flag_arr;
    detail_struct.conf_vec=conf_vec;
 detail_struct.timing=toc(t_s);
 
end