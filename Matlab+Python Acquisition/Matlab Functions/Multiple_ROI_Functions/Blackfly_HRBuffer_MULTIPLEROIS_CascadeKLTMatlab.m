function output_struct=Blackfly_HRBuffer_MULTIPLEROIS_CascadeKLTMatlab(Refresh_struct)
%% Get point trackers and face detectors
pointTracker_Chest=Refresh_struct.pointTracker_Chest;
pointTracker_Face=Refresh_struct.pointTracker_Face;
faceDetector_IR=Refresh_struct.faceDetector_IR;
ROI_Mask_Arr=Refresh_struct.ROI_Mask_Arr;
KLT_conf=Refresh_struct.KLT_conf;
Refresh_ROI_Frames=Refresh_struct.Refresh_ROI_Frames;


rc=Refresh_struct.refresh_cycles;
orig_data=Refresh_struct.init_buffer;
debug_buffer=orig_data; % Stores ALL DATA. Eventually we will not need this
ctr=2;
hr=Refresh_struct.hr;
tp=Refresh_struct.tp;

% making figure here
figure
nrows=2;
ncols=3;

for rr=1:nrows
    p{rr*ncols}=subplot(nrows,ncols,rr*ncols);scatter(tp{rr},hr{rr});title(strcat("Pulse per min vs Time",num2str(rr)));xlabel("time(s)");ylabel("HR(bpm")
    hold on;
end

for i=1:rc % 1 to refresh cycle
    image_struct=BlackFly_TakeImgv2(Refresh_struct.vid,Refresh_struct.framestorun+ Refresh_struct.exc_frames,  Refresh_struct.cam_init_flag); % TAKE IMAGES % take images
    %image_struct=BlackFly_TakeImg(Refresh_struct.vid,Refresh_struct.framestorun+ Refresh_struct.exc_frames); % take images
    %Debug_img_struct(i)=image_struct;
    % ASSUME SAME ROI-- Otherwise WE NEED TO REASSIGN BOUNDING BOX VALUES HERE.
    %% AUTOMATED ROI
    [DetectedFaceStruct,DetectedChestStruct,detail_struct]=GetFaceandChestROI(image_struct,faceDetector_IR,pointTracker_Face,pointTracker_Chest,KLT_conf,Refresh_ROI_Frames);
    
    for j=1:length(DetectedFaceStruct)
       BBox{j,1}= round(DetectedFaceStruct{j}.newBBox);
       BBox{j,2}= round(DetectedChestStruct{j}.Chest_BBox);
    end
    [Testing,New_ROI_vec,new_time_stamps,Last_Image]=CroptoROI_FrameRange_MULTIPLEROIS_MatlabKLTCascade(image_struct,BBox,ROI_Mask_Arr);
    
    %[~,New_ROI_vec,new_time_stamps,Last_Image]=CroptoROI_FrameRange_MULTIPLEROIS(image_struct, Refresh_struct.BBox,Refresh_struct.exc_frames);
    %% Rewriting new data
    for rr=1:nrows % number of bboxes
        temp=debug_buffer{rr};
        temp=circshift(temp,-Refresh_struct.framestorun);
        temp(end-Refresh_struct.framestorun+1:end)=New_ROI_vec{rr};
        debug_buffer{rr}=temp; % new data-- Storing all of i
        New_Data{rr}=temp;
    end
    %% EMD Decomposition
    [recon_signal,imf,info,residual,imf_idx_1,imf_idx_2]= EMD_Analysis_MULTIPLEROIS(New_Data,Refresh_struct.imf_mat);disp("WITHOUT SPLINING")
    for rr=1:nrows % box
        filtered_recon{rr}=filter(Refresh_struct.filter_b{rr},1,recon_signal{rr}); % APPLYING FILTER
        Analyzed_fourier{rr}=Fourier_Representation(Refresh_struct.fs_est,Refresh_struct.timestamps,filtered_recon{rr});
        debug_fourier{rr}(i)=Analyzed_fourier{rr}; % debugging and storing all fourir analysis
        hr{rr}(ctr)=60*Analyzed_fourier{rr}.freq_max;
        tp{rr}(ctr)=toc(Refresh_struct.tStart);
        
        % plt idxs
        plt_idx1=(ncols*rr)-(ncols-1);
        plt_idx2=plt_idx1+1;
        plt_idx3=plt_idx2+1;
        
        if i==1
            p_ax{plt_idx1}=subplot(nrows,ncols,plt_idx1);p{plt_idx1}=imagesc(Last_Image{rr});colorbar;title("last frame");
            p{plt_idx2}=subplot(nrows,ncols,plt_idx2);plt_handle{rr}=plot(Analyzed_fourier{rr}.freq_fft,Analyzed_fourier{rr}.freq_amp);
            title(strcat("BP=",num2str(Refresh_struct.bp_mat{rr})," EMD=",num2str(Refresh_struct.imf_mat{rr})))
            scatter(p{plt_idx3},tp{rr}(ctr),hr{rr}(ctr));
            drawnow
        else
            imagesc(p_ax{plt_idx1},Last_Image{rr});colorbar
            %set(p{plt_idx1},'CData',Last_Image{rr});
            set(plt_handle{rr},'YData',Analyzed_fourier{rr}.freq_amp);
            %title(strcat("bp=",num2str(Refresh_struct.bp_mat{rr}),"EMD=",num2str(Refresh_struct.imf_mat{rr})))
            scatter(p{plt_idx3},tp{rr}(ctr),hr{rr}(ctr));
            drawnow
            
            
        end
        
        
        
        
        %% adding to output struct
        
        
        %output_struct.Debug_img_struct=Debug_img_struct;
    end
    output_struct.hr=hr;
    output_struct.tp=tp;
    output_struct.refresh_analysis_time(i)=image_struct.total_analysis_time;
    % debugging elements.
    output_struct.debug_buffer=debug_buffer;
    output_struct.debug_fourier=debug_fourier;
    output_struct.frame_rate_est(i)=image_struct.frame_rate_est;
    output_struct.Refresh_struct=Refresh_struct;
    beep % sound when finished
    i;disp(get(Refresh_struct.vid,'FramesAvailable'))
    ctr=ctr+1;
    clear image_struct % for memory
end

end