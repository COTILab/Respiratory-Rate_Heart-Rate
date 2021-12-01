function out_struct=buffer_main(buffer_struct,signalProcessing,finalSignal,interp_struct_inp)
%% Written on 30NOV21 -- handles buffering
% Inputs:
% 1.buffer_struct:




%% copying parameters
out_struct.HR_coh=finalSignal.HR_coherenceBased; % coherence based-- will append
out_struct.HR_pow=finalSignal.HR_powerBased; % power based- will append
out_struct.times=finalSignal.t_total;
init_buffer=interp_struct_inp; % initial interpolated wrt time -channels
%% Relevant Parameters
refresh_frames=buffer_struct.refresh_frames; % number of new frames to take before we reanalyze
buffer_cycles=buffer_struct.buffer_cycles;
dead_frames=buffer_struct.dead_frames; % dead frames to cut out 
%% Trackers
pointTracker_Face=buffer_struct.pointTracker_Face;
pointTracker_Chest=buffer_struct.pointTracker_Chest;
faceDetector=buffer_struct.faceDetector;
Refresh_ROI_Frames=buffer_struct.Refresh_ROI_Frames;
KLT_conf=buffer_struct.KLT_conf;
%% Main script
figure;buffer_visualization (signalProcessing,finalSignal,out_struct) % first point
 % plot first point 
for i=1:buffer_cycles
    new_t_start=tic;
    image_struct=Take_Internal_Webcam_Images(refresh_frames,dead_frames); % take images
    [DetectedFaceStruct,~,detail_struct]=GetFaceandChestROI(image_struct,faceDetector,pointTracker_Face,pointTracker_Chest,KLT_conf,Refresh_ROI_Frames); % find faces
    DetectedFaceStruct=Fill_in_Face_Struct(DetectedFaceStruct); % fill in face structure
    [Masked_Images,pixelValPerFrame,t_mask]=K_Means_Masking(image_struct,DetectedFaceStruct); % Mask images
    interp_struct=Spline_3_channel(signalProcessing,image_struct,pixelValPerFrame); % Interpolate to match target frame rate
    %% THIS IS WHERE WE INTEGRATE OUR BUFFER- WE CANNOT DO IT POST ICA Due to Seeding errors when we use ICA( using ICA on exact same input does not guaranteee IDENTICAL output)
    new_buffer_struct=Color_Buffer_Shift(init_buffer,interp_struct);
    init_buffer=new_buffer_struct; % Overwriting buffer for next iteration
    %% Proceed as normal through our analysis
    filt1_struct=Remove_LowPassFilt_1(signalProcessing,new_buffer_struct); % low pass filter- 1
    finalSignal=fastICA_analysis_2(signalProcessing,filt1_struct); % RUN ICA
    [signalProcessing,finalSignal]=GenPowerSpectrum_3(signalProcessing,finalSignal);
    finalSignal =LowPass_PSDCoherence_4(signalProcessing,finalSignal);
    [finalSignal]=Coherence_Power_HRanalysis_5(signalProcessing,finalSignal);
    %% Adding to final struct
    out_struct.HR_coh(i+1)=finalSignal.HR_coherenceBased;
    out_struct.HR_pow(i+1)=finalSignal.HR_powerBased;
    out_struct.times(i+1)=out_struct.times(i)+toc(new_t_start); % new times
    %% Visualizing each point
    buffer_visualization (signalProcessing,finalSignal,out_struct)
    
    
    
    
end
%% Add statistics for analysis
out_struct.med_HR_pow= median(out_struct.HR_pow);
out_struct.std_HR_pow= std(out_struct.HR_pow,0,2);

out_struct.med_HR_coh= median(out_struct.HR_coh);
out_struct.std_HR_coh= std(out_struct.HR_coh,0,2);
display("DONE ACQUIRING")








end


