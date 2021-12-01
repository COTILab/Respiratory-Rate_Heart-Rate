close all
clear all
clc
clear classes
%% Fixed Variables-- for live view
%%%%%%%%%%%%%%%
%% flags
face_det_flag=0; % 1 if we use open CV to locate face, 0 if we want to manually choose ROI
% analysis flags
MLSVD_Analysis_Flag=0; % 1 if we are we analyzing using MLSVD
EMD_Analysis_Flag=1; %  1 if we are analyzing using EMD methods
%% end flags
fs_est=30; disp(strcat("SAMPLING FREQ=",num2str(fs_est)));%30; % 30 hz. we will interpolate to this frequency in analysis as well
Analysis_time=3.3;  % time in seconds
Refresh_time=0.1; % time in seconds before we reanalyze 
Init_tc=0; % how much of our initial signal do we cut out 
% Just as an example: Analysis_time=5, Refresh_time=1, means we always
% analyze 5 seconds worth of data at a time. However, we update the 5
% second window by taking 1 additional second of data and then reanalyzing.
% That means our EFFECTIVE framerate for the heartrate is ROUGHLY 1 Hz 
init_tc_frame_count=round(Init_tc/(1/fs_est));
Analysis_frame_count=round(Analysis_time/(1/fs_est));% converts time to frames as an estimate-- Rounds to whole number of frames
Refresh_frame_count=round(Refresh_time/(1/fs_est)); % coverts time to frames as an estimate-- Rounds to whole number of frames
%% band pass parameters
  bp_mat=[0.8 3.2]; % bandpass range
   Wn=(2/fs_est).*bp_mat; % normalize freqs-- based on nyquist
   n=127; % how any points on hamming window and the order
   b=fir1(n,Wn,hamming(n+1));
   fvtool(b,1,'Fs',fs_est) % visualizing bandpass
%%%%%%%%%%%%%%%%%%%%%
%% adding relevant paths
modpath='./Python Functions';
matlabfun_path='./Matlab Functions';
addpath(genpath(modpath));
addpath(genpath(matlabfun_path));
% reload python modules


%
%% Initialization-- Turns on video streams
VideoStreams=Camera_Initialization(modpath);

m=py.importlib.import_module('CameraFunctions');
py.importlib.reload(m);
%% Take first set of images and analyze them. This happens BEFORE the while loop to create the initial buffer
%num_frames=160; % for live view purposes
dim1=320; % currently fixed for camera 
dim2=240; % currently fixed for camera
% taking images first set 
image_struct_first=Take_Images_Fixed(VideoStreams,init_tc_frame_count+Analysis_frame_count,fs_est,dim1,dim2);
%I2=uint8(image_struct_first.images(:,:,2)');
%I=cat(3, uint8(image_struct_first.images(:,:,2)'), uint8(image_struct_first.images(:,:,2)'),uint8(image_struct_first.images(:,:,2)'));
%[bboxes, scores, landmarks] = mtcnn.detectFaces(I);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Getting ROIs

%% Face
if face_det_flag==1 % if we want to detect faces using openCV
    sf=1.2;
    mn=3;
    BBbox=get_ROI_Face_mat(uint8(image_struct_first.images(:,:,end)),sf,mn);
end
%% Manual ROI Selection
if face_det_flag==0 % if we want to select an ROI manually
    BBox=Manual_ROI_Selection(image_struct_first.images(:,:,end));
    
end

%% Crop images based on BBox ranges-->  Also cuts out the number of specified frames
[Avg_ROI,Avg_ROI_vec,new_time_stamps]=CroptoROI_FrameRange(image_struct_first,BBox,init_tc_frame_count);
[Avg_ROI_nfs,Avg_ROI_vec_nfs,ori_time_stamps]=CroptoROI_FrameRange(image_struct_first,BBox,1); % no time cut off

%% Original filtering--> Right now we either do empirical mode decomposition or MLSVD
%% First we spline
if EMD_Analysis_Flag==1 % EMD Analysis flag. This means we only work with the 1D Avg_ROI_vec time series
   [Splined_times,Splined_Signal]= EMD_Splining_Signal(fs_est,Avg_ROI_vec,new_time_stamps,Analysis_time);
   %% for visualization for spline 
   
   %figure;plot(Splined_times,Splined_Signal);hold on; plot(new_time_stamps,Avg_ROI_vec);
    
   %% end visualization for spline 
   % recontructed EMD based analysis in time domain
   [recon_signal,imf,info,residual,imf_idx_1,imf_idx_2]= EMD_Analysis(Splined_Signal);disp("WITH SPLINING")
   %% Apply bandpass and fourier transform
   % https://www.mathworks.com/help/signal/ug/filtering-data-with-signal-processing-toolbox.html
   filtered_recon=filter(b,1,recon_signal); % APPLYING FILTER
   Analyzed_fourier=Fourier_Representation(fs_est,Splined_times,filtered_recon);
   %% plotting for now freq response
   figure;plot(Analyzed_fourier.freq_fft,Analyzed_fourier.freq_amp)
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% For refreshing signal and adding to buffer
   Analysis_figure=figure;
   nrows=1;
   ncols=3;
   ax1=subplot(nrows,ncols,1);
   ax2=subplot(nrows,ncols,2);
   ax3=subplot(nrows,ncols,3); hold on
   im1=imagesc(ax1,Avg_ROI(:,:,end));colorbar;title("The Last Frame")
   plot(ax2,Analyzed_fourier.freq_fft,Analyzed_fourier.freq_amp);title("Freq Response");xlabel("Freq(hz)");ylabel("Counts")
   scatter(ax3,Splined_times(end),Analyzed_fourier.freq_max*60);title("heart rate vs time");xlabel("time(s)");ylabel("Heart rate(bpm)")
   
   %% TIHS IS WHERE INFINITY WHILE LLOOP WOULD BE
   refresh_cycles=100; % how many times do we take new signals (refresh rate)
   ctr=1; 
   time_start=tic;
   time_ctr=Splined_times(end);
   Updated_Signal(ctr,:)=Splined_Signal; % original signal to circshift and then overwrite
   while (ctr<=refresh_cycles)
       cycle_ts=tic;
       %while(true)
       new_image_struct=Take_Images_Fixed(VideoStreams,Refresh_frame_count,fs_est,dim1,dim2); % newrefreshed images
       %% For now ASSUME SAME BOUNDING BOX.. WE DO NOT UPDATE THE BOUNDING BOX WITH TIME FOR TESTING NOW
       [New_ROI,New_ROI_vec,ref_time_stamps]=CroptoROI_FrameRange(new_image_struct,BBox,0);
       % debug storage
       ROI_vec_refr_storage(:,ctr)=New_ROI_vec;
       ROI_vec_refr_sm(ctr)=mean(ROI_vec_refr_storage(:,ctr));
       %
       [New_Splined_times,New_Splined_Signal]= EMD_Splining_Signal(fs_est,New_ROI_vec,ref_time_stamps,Refresh_time);
       %% Circshift in time domain now that we are splined, reanalyze, etc
        Updated_Signal(ctr+1,:)=circshift(Updated_Signal(ctr,:),-length(New_Splined_Signal)); % slide buffer
        temp=Updated_Signal(ctr+1,:);
        temp(length(temp)-length(New_Splined_Signal)+1:length(temp))=New_Splined_Signal; % Overwrite the buffer
        Updated_Signal(ctr+1,:)=temp;
       %% Now Continue Analyzing the signal the same way--> EMD+Fourier+bandpass-->Primary freq component
        [recon_signal_refr,imf_refr,info_refr,residual_refr,imf_idx_1_refr,imf_idx_2_refr]= EMD_Analysis(Updated_Signal(ctr+1,:));disp("WITH SPLINING")
       
       % NO BUFFER,JUST TAKE NEW DATA
       %[recon_signal_refr,imf_refr,info_refr,residual_refr,imf_idx_1_refr,imf_idx_2_refr]= EMD_Analysis(New_Splined_Signal);disp("NO SPLINING")
       
       filtered_recon_refr=filter(b,1,recon_signal_refr); % APPLYING FILTER
       Analyzed_fourier_refr(ctr)=Fourier_Representation(fs_est,Splined_times,filtered_recon_refr);
       
       %% Updating Plots
       
       time_ctr= time_ctr+toc(cycle_ts);%New_Splined_times(end); % what we will scatter
       set(im1,'CData',New_ROI(:,:,end));colorbar(ax1);title(ax1,"The Last Frame")
   plot(ax2,Analyzed_fourier_refr(ctr).freq_fft,Analyzed_fourier_refr(ctr).freq_amp);title(ax2,"Freq Response");xlabel(ax2,"Freq(hz)");ylabel(ax2,"Counts")
  
       
       
       
       
       
       scatter(ax3,time_ctr,Analyzed_fourier_refr(ctr).freq_max*60);title("heart rate vs time");xlabel("time(s)");ylabel("Heart rate(bpm)")
       ctr=ctr+1; % incrementing counter
       time_end(ctr)=time_ctr;%toc(time_start);
   end % end of while loop
   figure;plot(time_end)
   disp("FINISHED ACQUIRING DATA")
   py.CameraFunctions.kill_both_streams(VideoStreams); % Shutting down the streams
    figure;plot(time_end,1,'ro');title("time points post refresher(seconds)");xlabel("time");ylabel("Marker")
    time_diff=diff(time_end);
    figure;histogram(time_diff(2:end));
    
end % end EMD analysis
% we initially spline+Interpolate our data to the same window length in time
% that we specified. This way, if we have any hitches in our frames/
% analysis causes any delays, we still have a "Consistent" data set for
% every window that we can analyze

% temp=uint8(image_struct_first.images(:,:,end));
% temp_3=cat(3,temp,temp,temp);
% sf=1.2;mn=3; % face parameters
% face_dims=(py.CameraFunctions.get_ROI_FACE(temp_3,sf,mn)); % give RGB image even though its grayscale
% for i=1:size(face_dims,1)
%     for j=1:size(face_dims,1)
%         temp=uint32(face_dims{i,j});
%         face_dims_conv(i,j,:)=temp;
%     end
% end
% face_dims_conv=squeeze(face_dims_conv);



