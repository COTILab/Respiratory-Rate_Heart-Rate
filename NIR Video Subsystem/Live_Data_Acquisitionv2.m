close all
clear all
clc
clear classes
%% Fixed Variables-- for live view
%%%%%%%%%%%%%%%
%% VERSION 2--21SEP21: Uses Python to run all acquisition. Minimizes matlab--> python transitions. should have more consistent acquistion speeds
%% flags
face_det_flag=1; % 1 if we use open CV to locate face, 0 if we want to manually choose ROI
MLSVD_FilterXY_Flag=0; % Filtering images in X and Y using MLSVD
% analysis flags
MLSVD_Analysis_Flag=0; % 1 if we are we analyzing using MLSVD
EMD_Analysis_Flag=1; %  1 if we are analyzing using EMD methods
%% end flags
%fs_est=30; disp(strcat("SAMPLING FREQ=",num2str(fs_est)));%30; % 30 hz. we will interpolate to this frequency in analysis as well
%Analysis_time=3.3;  % time in seconds
%Refresh_time=0.1; % time in seconds before we reanalyze
%Init_tc=0; % how much of our initial signal do we cut out
% Just as an example: Analysis_time=5, Refresh_time=1, means we always
% analyze 5 seconds worth of data at a time. However, we update the 5
% second window by taking 1 additional second of data and then reanalyzing.
% That means our EFFECTIVE framerate for the heartrate is ROUGHLY 1 Hz
init_tc_frame_count=1;%round(Init_tc/(1/fs_est));
Analysis_frame_count=300;%round(Analysis_time/(1/fs_est));% converts time to frames as an estimate-- Rounds to whole number of frames
Refresh_frame_count=300;%round(Refresh_time/(1/fs_est)); % coverts time to frames as an estimate-- Rounds to whole number of frames
time_d=0; % delay between images passed to python-- indirectly affects frame rate
%% band pass parameters
bp_mat=[0.6 3.2]; % bandpass range--> Freqs in hertz
% Wn=(2/fs_est).*bp_mat; % normalize freqs-- based on nyquist
%n=127; % how any points on hamming window and the order
%b=fir1(n,Wn,hamming(n+1));
%fvtool(b,1,'Fs',fs_est) % visualizing bandpass
%%%%%%%%%%%%%%%%%%%%%
%% adding relevant paths
modpath='./Python Functions';
matlabfun_path='./Matlab Functions';
addpath(genpath(modpath));
addpath(genpath(matlabfun_path));
% reload python modules


%
%% Initialization-- Turns on video streams
VideoStreams=Camera_Initialization(modpath); % initialize
py.CameraFunctions.kill_both_streams(VideoStreams) % kill
pause(1)
VideoStreams=Camera_Initialization(modpath); % initialize
pause(1)


m=py.importlib.import_module('CameraFunctions');
py.importlib.reload(m);
%% Take first set of images and analyze them. This happens BEFORE the while loop to create the initial buffer
%num_frames=160; % for live view purposes
dim1=320; % currently fixed for camera
dim2=240; % currently fixed for camera
% taking images first set

image_struct_first=Take_Images_Fixedv2(VideoStreams,init_tc_frame_count+Analysis_frame_count,time_d,dim1,dim2);
if MLSVD_FilterXY_Flag==1
    vf=0.96; % percent of variation we want to explain
    image_struct_first=MLSVD_XY_Filt(image_struct_first,vf);
end
%I2=uint8(image_struct_first.images(:,:,2)');
%I=cat(3, uint8(image_struct_first.images(:,:,2)'), uint8(image_struct_first.images(:,:,2)'),uint8(image_struct_first.images(:,:,2)'));
%[bboxes, scores, landmarks] = mtcnn.detectFaces(I);
% visualizing bandpass
fs_est=(image_struct_first.fs_est);
Wn=(2/fs_est).*bp_mat; % normalize freqs-- based on nyquist
n=127; % how any points on hamming window and the order
b=fir1(n,Wn,hamming(n+1));
fvtool(b,1,'Fs',fs_est) % visualizing bandpass

%Analysis_time=3.3;  % time in seconds
%Refresh_time=0.1; % time in seconds before we reanalyze

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Getting ROIs

%% Face
if face_det_flag==1 % if we want to detect faces using openCV
    sf=1.5;
    mn=3% 3;
    BBox=get_ROI_Face_mat((image_struct_first.images(:,:,10)),sf,mn);
    ctr=1
     for i=1:size(image_struct_first.images,3)
         try
             BBox(:,ctr)=get_ROI_Face_mat(uint8(image_struct_first.images(:,:,i)),sf,mn);
             ID(ctr)=i;
             %break;
             ctr=ctr+1;
         catch 
         end
     end
        
    %     blah=tic;
    %figure
    %for i=1:size(image_struct_first.images,3)
    %   BBox=get_ROI_Face_mat(uint8(image_struct_first.images(:,:,i)),sf,mn);
    %    BBox_mat(:,i)=BBox;
    %     rahul(i)=toc(blah);
    %   roi=BBox_mat(:,i);
    
    %
    %  ROI_dim1_start=roi(2)+5;%100;;%85;%126;
    % ROI_dim1_end=roi(2)+roi(4)-5;%182;%144;
    %  ROI_dim2_start=roi(1)+5;%136;%86;%161;
    % ROI_dim2_end=roi(1)+roi(3)-5;%193;%183;%176;
    %
    %Avg_ROI{i}=image_struct_first.images(ROI_dim1_start:ROI_dim1_end,ROI_dim2_start:ROI_dim2_end,i);
    
    %temp =Avg_ROI{i};
    %tempFWHM = (nanmedian(temp(:)));
    %temp(temp <= (tempFWHM/2)) = NaN;
    %Avg_ROI{i} = temp;
    %Avg_ROI_vec(i) = nanmean(temp(:));
    
    
    
    
    % Avg_ROI_vec(i)=nanmean(nanmean(double(Avg_ROI{i})));
    
    %imagesc(Avg_ROI{i});colorbar;title(i)
    %pause(0.01);
    
    %end
    try
        [Avg_ROI,new_time_stamps,Avg_ROI_vec,BBox_mat]=CroptoROI_multframes(image_struct_first.images,image_struct_first.time_stamp,sf,mn,init_tc_frame_count);
        figure;imagesc(Avg_ROI{1});colorbar;title(1)
    catch
        disp("CANT DETECT FACE WITH OPEN CV")
        face_det_flag=0;
    end
    
    
    %new_time_stamps=image_struct_first.time_stamp(2:end);
    %Avg_ROI_vec=Avg_ROI_vec(2:end);
end
%% Manual ROI Selection
if face_det_flag==0 % if we want to select an ROI manually
    BBox=Manual_ROI_Selection(image_struct_first.images(:,:,end));
    
end

%% Crop images based on BBox ranges-->  Also cuts out the number of specified frames
if face_det_flag==0
    [Avg_ROI,Avg_ROI_vec,new_time_stamps]=CroptoROI_FrameRange(image_struct_first,BBox,init_tc_frame_count);
    [Avg_ROI_nfs,Avg_ROI_vec_nfs,ori_time_stamps]=CroptoROI_FrameRange(image_struct_first,BBox,1); % no time cut off
end

disp("DEBUGGING DOING SOMETHING REALLY DUMB HERE")
Analysis_time=1/round(fs_est)*Analysis_frame_count;  % time in seconds
Refresh_time=1/round(fs_est)*Refresh_frame_count; % time in seconds before we reanalyze
disp("DEBUGGING DOING SOMETHING REALLY DUMB HERE")

%% Original filtering--> Right now we either do empirical mode decomposition or MLSVD
%% First we spline
if EMD_Analysis_Flag==1 % EMD Analysis flag. This means we only work with the 1D Avg_ROI_vec time series
    [Splined_times,Splined_Signal]= EMD_Splining_Signal(fs_est,Avg_ROI_vec,new_time_stamps,Analysis_time);
    %% for visualization for spline
    
    %figure;plot(Splined_times,Splined_Signal);hold on; plot(new_time_stamps,Avg_ROI_vec);
    
    %% end visualization for spline
    % recontructed EMD based analysis in time domain
    [recon_signal,imf,info,residual,imf_idx_1,imf_idx_2]= EMD_Analysis(Splined_Signal);disp("WITH SPLINING")
    Analyzed_fourier_NOBP=Fourier_Representation(fs_est,Splined_times,recon_signal); % no bp
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
    if face_det_flag==1
        im1=imagesc(ax1,Avg_ROI{end});colorbar;title("The Last Frame")
    end
    if face_det_flag==0
        im1=imagesc(ax1,Avg_ROI(:,:,end));colorbar;title("The Last Frame")
    end
    
    plot(ax2,Analyzed_fourier.freq_fft,Analyzed_fourier.freq_amp);title("Freq Response");xlabel("Freq(hz)");ylabel("Counts")
    scatter(ax3,Splined_times(end),Analyzed_fourier.freq_max*60);title("heart rate vs time");xlabel("time(s)");ylabel("Heart rate(bpm)")
    drawnow
    %% TIHS IS WHERE INFINITY WHILE LLOOP WOULD BE
    refresh_cycles=5; % how many times do we take new signals (refresh rate)
    ctr=1;
    time_start=tic;
    time_ctr=Splined_times(end);
    Updated_Signal(ctr,:)=Splined_Signal; % original signal to circshift and then overwrite
    while (ctr<=refresh_cycles)
        cycle_ts=tic;
        %while(true)
        disp("Adding killing the camera, restarting it, and adding dummy frames at beginning to excise")
        %% restarting camera
        py.CameraFunctions.kill_both_streams(VideoStreams) % kill
        pause(1)
        VideoStreams=Camera_Initialization(modpath); % initialize
        pause(1)
        %% end restarting camera
        %% WITH NO CAMERA RESET WE HAVE NO DUMMY IMAGES
        %new_image_struct=Take_Images_Fixedv2(VideoStreams,Refresh_frame_count,time_d,dim1,dim2);
        %% For now ASSUME SAME BOUNDING BOX.. WE DO NOT UPDATE THE BOUNDING BOX WITH TIME FOR TESTING NOW
        %[New_ROI,New_ROI_vec,ref_time_stamps]=CroptoROI_FrameRange(new_image_struct,BBox,0);
        disp( "DUMMY IMAGES WITH BUFFER")
        new_image_struct=Take_Images_Fixedv2(VideoStreams,Refresh_frame_count+init_tc_frame_count,time_d,dim1,dim2);
        if MLSVD_FilterXY_Flag==1
            new_image_struct=MLSVD_XY_Filt( new_image_struct,vf);
        end
        debug_struct(ctr)=new_image_struct;
        if face_det_flag==0 % manual ROI NON OPEN CV
            %For now ASSUME SAME BOUNDING BOX.. WE DO NOT UPDATE THE BOUNDING BOX WITH TIME FOR TESTING NOW
            %disp("Picking Bounding box new every time we refresh")
            %BBox=Manual_ROI_Selection(new_image_struct.images(:,:,end)); % COMMENT THIS OUT TO USE OLD BBOX EVERY TIME
            %close
            [New_ROI,New_ROI_vec,ref_time_stamps]=CroptoROI_FrameRange(new_image_struct,BBox,init_tc_frame_count);
            debug_ROI_vec(ctr,:)= New_ROI_vec; % 
        else
            
            [New_ROI,ref_time_stamps,New_ROI_vec,New_BBox_mat]=CroptoROI_multframes(new_image_struct.images,new_image_struct.time_stamp,sf,mn,init_tc_frame_count);
            %%%% OPEN CV NOW
            %for i=1:size(new_image_struct.images,3)
            %BBox=get_ROI_Face_mat(uint8(new_image_struct.images(:,:,i)),sf,mn);
            %BBox_mat(:,i)=BBox;
            %     rahul(i)=toc(blah);
            %roi=BBox_mat(:,i);
            %
            %ROI_dim1_start=roi(2)+5;%100;;%85;%126;
            %ROI_dim1_end=roi(2)+roi(4)-5;%182;%144;
            %ROI_dim2_start=roi(1)+5;%136;%86;%161;
            %ROI_dim2_end=roi(1)+roi(3)-5;%193;%183;%176;
            %
            % New_ROI{i}=new_image_struct.images(ROI_dim1_start:ROI_dim1_end,ROI_dim2_start:ROI_dim2_end,i);
            
            % temp =New_ROI{i};
            % tempFWHM = (nanmedian(temp(:)));
            % temp(temp <= (tempFWHM/2)) = NaN;
            %  New_ROI{i} = temp;
            %Avg_ROI_vec(i) = nanmean(temp(:));
            
            
            
            
            %   New_ROI_vec(i)=nanmean(nanmean(double(New_ROI{i})));
            
            %imagesc(Avg_ROI{i});colorbar;title(i)
            %pause(0.01);
            
            %end
            
            %ref_time_stamps=new_image_struct.time_stamp(2:end);
            %New_ROI_vec= New_ROI_vec(2:end);
            
            
        end
        %Take_Images_Fixed(VideoStreams,Refresh_frame_count,fs_est,dim1,dim2); % newrefreshed images
        
        % debug storage
        ROI_vec_refr_storage(:,ctr)=New_ROI_vec;
        ROI_vec_refr_sm(ctr)=mean(ROI_vec_refr_storage(:,ctr));
        %
        [New_Splined_times,New_Splined_Signal]= EMD_Splining_Signal(fs_est,New_ROI_vec,ref_time_stamps,Refresh_time);
        %% Circshift in time domain now that we are splined, reanalyze, etc
        Updated_Signal(ctr+1,:)=circshift(Updated_Signal(ctr,:),-length(New_Splined_Signal)); % slide buffer
        temp=Updated_Signal(ctr+1,:);
        if(length(temp)+1>length(New_Splined_Signal))
            % partial overwrite
            temp(length(temp)-length(New_Splined_Signal)+1:length(temp))=New_Splined_Signal; % Overwrite the buffer
            Updated_Signal(ctr+1,:)=temp;
        else
            disp("DEBUGGING ONLY... EMPTYING SIGNAL EVERY TIME"); Updated_Signal=[];
            %Updated_Signal(:,end+1)=0; % padding with 0s.. I dont know why this is even happening...
           
            Updated_Signal(ctr+1,:)=New_Splined_Signal;
        end
        %% Now Continue Analyzing the signal the same way--> EMD+Fourier+bandpass-->Primary freq component
        [recon_signal_refr,imf_refr,info_refr,residual_refr,imf_idx_1_refr,imf_idx_2_refr]= EMD_Analysis(Updated_Signal(ctr+1,:));disp("WITH SPLINING")
        
        % NO BUFFER,JUST TAKE NEW DATA
        %[recon_signal_refr,imf_refr,info_refr,residual_refr,imf_idx_1_refr,imf_idx_2_refr]= EMD_Analysis(New_Splined_Signal);disp("NO SPLINING")
        
        filtered_recon_refr=filter(b,1,recon_signal_refr); % APPLYING FILTER
        Analyzed_fourier_refr(ctr)=Fourier_Representation(fs_est,Splined_times,filtered_recon_refr);
        
        %% Updating Plots
        
        time_ctr= time_ctr+toc(cycle_ts);%New_Splined_times(end); % what we will scatter
        if face_det_flag==1
            imagesc(ax1,New_ROI{end});colorbar(ax1);title(ax1,"The Last Frame")
        end
        
        if face_det_flag==0
            im1=imagesc(ax1,New_ROI(:,:,end));colorbar;title("The Last Frame")
        end
        plot(ax2,Analyzed_fourier_refr(ctr).freq_fft,Analyzed_fourier_refr(ctr).freq_amp);title(ax2,"Freq Response");xlabel(ax2,"Freq(hz)");ylabel(ax2,"Counts")
        
        
        
        
        
        
        scatter(ax3,time_ctr,Analyzed_fourier_refr(ctr).freq_max*60);title("heart rate vs time");xlabel("time(s)");ylabel("Heart rate(bpm)")
        ctr=ctr+1; % incrementing counter
        time_end(ctr)=time_ctr;%toc(time_start);
        drawnow
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



