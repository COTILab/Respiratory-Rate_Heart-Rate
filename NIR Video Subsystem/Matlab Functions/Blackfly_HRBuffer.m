function output_struct=Blackfly_HRBuffer(Refresh_struct)

rc=Refresh_struct.refresh_cycles;
orig_data=Refresh_struct.init_buffer;
debug_buffer=orig_data; % Stores ALL DATA. Eventually we will not need this
ctr=2;
hr=Refresh_struct.hr;
tp=Refresh_struct.tp;

% making figure here
figure
nrows=1;
ncols=3;


p3=subplot(nrows,ncols,3);scatter(tp,hr);title("Heart Rate vs Time");xlabel("time(s)");ylabel("HR(bpm")
hold on;

for i=1:rc % 1 to refresh cycle
    image_struct=BlackFly_TakeImgv2(Refresh_struct.vid,Refresh_struct.framestorun+ Refresh_struct.exc_frames,  Refresh_struct.cam_init_flag); % TAKE IMAGES % take images
    %image_struct=BlackFly_TakeImg(Refresh_struct.vid,Refresh_struct.framestorun+ Refresh_struct.exc_frames); % take images
    %Debug_img_struct(i)=image_struct;
    % ASSUME SAME ROI-- Otherwise WE NEED TO REASSIGN BOUNDING BOX VALUES HERE.
    [~,New_ROI_vec,new_time_stamps,Last_Image]=CroptoROI_FrameRange(image_struct, Refresh_struct.BBox,Refresh_struct.exc_frames);
    %% Rewriting new data
    temp=debug_buffer;
    temp=circshift(temp,-Refresh_struct.framestorun);
    temp(end-Refresh_struct.framestorun+1:end)=New_ROI_vec;
    debug_buffer=temp; % new data-- Storing all of i
    New_Data=temp;
    %% EMD Decomposition
    [recon_signal,imf,info,residual,imf_idx_1,imf_idx_2]= EMD_Analysis(New_Data);disp("WITHOUT SPLINING")
    filtered_recon=filter(Refresh_struct.filter_b,1,recon_signal); % APPLYING FILTER
    Analyzed_fourier=Fourier_Representation(Refresh_struct.fs_est,Refresh_struct.timestamps,filtered_recon);
    debug_fourier(i)=Analyzed_fourier; % debugging and storing all fourir analysis
    hr(ctr)=60*Analyzed_fourier.freq_max;
    tp(ctr)=toc(Refresh_struct.tStart);
    
    if i==1
        subplot(nrows,ncols,1);p1=imagesc(Last_Image);colorbar;title("last frame");
        p2=subplot(nrows,ncols,2);plot(Analyzed_fourier.freq_fft,Analyzed_fourier.freq_amp);
        scatter(p3,tp(ctr),hr(ctr));
        drawnow
    else
        set(p1,'CData',Last_Image);
        plot(p2,Analyzed_fourier.freq_fft,Analyzed_fourier.freq_amp)
        scatter(p3,tp(ctr),hr(ctr));
        drawnow
        
        
    end
    
    
    
    ctr=ctr+1;
    %% adding to output struct
    output_struct.hr=hr;
    output_struct.tp=tp;
    output_struct.refresh_analysis_time(i)=image_struct.total_analysis_time;
    % debugging elements.
    output_struct.debug_buffer=debug_buffer;
    output_struct.debug_fourier=debug_fourier;
    output_struct.frame_rate_est(i)=image_struct.frame_rate_est;
    beep % sound when finished
    i;disp(get(Refresh_struct.vid,'FramesAvailable'))
    clear image_struct % for memory
    %output_struct.Debug_img_struct=Debug_img_struct;
end
end