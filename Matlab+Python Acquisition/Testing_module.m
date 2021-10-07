%% 08SEP21 
% Testing Python Modules with occipital ST01 Sensor using OpenNI2 with
% Python modules
close all
clear all
clc
modpath='./Python Functions';
matlabfun_path='./Matlab Functions';
addpath(genpath(modpath));
addpath(genpath(matlabfun_path));


if count(py.sys.path, '') == 0
  insert(py.sys.path, int32(0), '');
end

P = py.sys.path;
if count(P,modpath) == 0
    insert(P,int32(0),modpath);
end

fs_est=30;

Initialization=py.CameraFunctions.initialize_ST01(); % initializes camera 
VideoStreams=py.CameraFunctions.start_IR_and_color();% Starts video streams
% tic

num_frames=600; % for live view purposes
dim1=320; % currently fixed for camera 
dim2=240; % currently fixed for camera
% taking images
image_struct=Take_Images_Fixed(VideoStreams,num_frames,fs_est,dim1,dim2);
% viewing the image output
rand_image=rand(size(image_struct.images(:,:,1)'));
figure;
viewed_image=imagesc(rand_image);
pause % manual input to view frames
for i=1:num_frames
   set(viewed_image,'CData',image_struct.images(:,:,i)');colorbar;
   title_str=strcat("Frame #",num2str(i)," time_stamp(s)-",num2str(image_struct.time_stamp(i)));
   title(title_str);
   pause(0.02);
end
% manually choosing ROI for now
roi=drawrectangle;
roi=round(roi.Position);

 %faceDetector = vision.CascadeObjectDetector();
%rahul=image_struct.images(:,:,30);
%rahul(:,:,2)=rahul(:,:,1);
%rahul(:,:,3)=rahul(:,:,1);
%rahul=image_struct.images(:,:,30);
%rahul(:,:,2)=0;
%rahul(:,:,3)=0;
%bbox = step(faceDetector,image_struct.images(:,:,end));

%%Since bounding box likely failed
ROI_dim2_start=roi(2);%100;;%85;%126;
ROI_dim2_end=roi(2)+roi(4);%182;%144;
ROI_dim1_start=roi(1);%136;%86;%161;
ROI_dim1_end=roi(1)+roi(3);%193;%183;%176;
 
clear ROI_image
for i=1:num_frames
    ROI_image(:,:,i)=image_struct.images(ROI_dim1_start:ROI_dim1_end,ROI_dim2_start:ROI_dim2_end,i);
    temp=ROI_image(:,:,i);
    avg_ROI_vec(i)=mean(temp(:));
end
figure;imagesc(ROI_image(:,:,end));colorbar
cropped_frame=125; % which frames do we want to cut off at beginning
ff_ROI_image=double(ROI_image(:,:,cropped_frame:end)); % Full image with cropped- frames-- We will feed this into our LMLSVD
%% raw data
ff_avg_ROI_vec=avg_ROI_vec(cropped_frame:end); % deleting first frame
ff_time_stamp=image_struct.time_stamp-image_struct.time_stamp(cropped_frame);
ff_time_stamp=ff_time_stamp(cropped_frame:end);
figure;plot(ff_time_stamp,ff_avg_ROI_vec);xlabel("time(s)");ylabel("Average Count");title("Raw Signal")

%% END DATA ACQ and RAW DATA-- ALL SIGNAL SPROCESSING
% Splining
fs=30; % sampling freq roughly
splined_time=0:(1/fs):(floor(max(ff_time_stamp)/(1/fs))*(1/fs)); % make sure we interpolate and NOT extrapolate at sampling frequency
for i=1:size(ff_ROI_image,1)
    for j=1:size(ff_ROI_image,2)
    temp_val=squeeze(ff_ROI_image(i,j,:));   
    temp_interp_arr(1,1,:)=(interp1(ff_time_stamp,temp_val,splined_time));
    interp_ROI_image(i,j,:)=temp_interp_arr;
    end
end
for k=1:size(interp_ROI_image,3) % splined frames
    temp=interp_ROI_image(:,:,k);
    interp_ROI_vec(k)=mean(temp(:));
end
figure;plot(ff_time_stamp,ff_avg_ROI_vec);xlabel("time(s)");ylabel("Average Count");
hold on
plot(splined_time,interp_ROI_vec);xlabel("time(s)");ylabel("Average Count");title("Raw Signal splined vs nonsplined")
legend("Original","Splined")

%% splining end




%% EMD Decomposition
%[imf,residual,info] = emd(ff_avg_ROI_vec,'SiftRelativeTolerance',0.2); %% No spline
[imf,residual,info] = emd(interp_ROI_vec,'SiftRelativeTolerance',0.2); disp("SPLINED EMD")

fs=30; % rouhgly 30 HZ
imf_idx_1=2; % which IMF do we want to use
imf_idx_2=size(imf,2); % imf end

imf_chosen=imf(:,imf_idx_1:imf_idx_2);

recon_signal_time_dom=sum(imf_chosen,2);
% ZERO MEAN
%recon_signal_time_dom=recon_signal_time_dom-mean(recon_signal_time_dom); disp("ZERO MEAN")
% END ZERO MEAN
figure;
%plot(ff_time_stamp,recon_signal_time_dom); %NO SPLINE
plot(splined_time,recon_signal_time_dom);
xlabel("time(s)");ylabel("Recon Signal");title("EMD Reconstructed- NO BP")
%% FFT first--EMD
fs=30; % sampling freq
Fourier_Data=Fourier_Representation(fs,ff_time_stamp,recon_signal_time_dom);
%L=max(ff_time_stamp)./(1/fs);
%n=2^nextpow2(L);
%Y=fft(recon_signal_time_dom,n); % frequency response
% single sided and double sided spectrum
%P2 = abs(Y/L);
%P1 = P2(1:n/2+1,:);
%P1(:,2:end-1) = 2*P1(:,2:end-1);

figure;
%freq_fft=(0:(fs/n):(fs/2-fs/n));
%freq_amp=P1(1:n/2);
plot(Fourier_Data.freq_fft,Fourier_Data.freq_amp);xlabel("Frequency(hz)");ylabel("Amplitude");title("EMD Decomp+ FFT No bandpass or Hamming window")
%% Bandpass EMD+ fourier again
bp_mat=[0.8 3.2];%[0.8 3.2]; % bandpass --low and high in Hz in 1x2 array

EMD_timedom_bp=bandpass_MLSVD(fs,recon_signal_time_dom,bp_mat);
EMD_freqdom_bp=Fourier_Representation(fs,splined_time,EMD_timedom_bp.output_signal);

%% %% %% % % MLSVD-- Derived from MM -11SEP21
%% Filter Data-- RAW ROI image
%% spline to be exactly the time frequency

%[U, S, sv] = mlsvd(double(ff_ROI_image),size(ff_ROI_image)); % original 
[U, S, sv] = mlsvd(double(interp_ROI_image),size(interp_ROI_image)); % original 


sv_norm{1} = (sv{1})./max((sv{1})); % Normalized singular values x
sv_norm{2} = (sv{2})./max((sv{2})); % Normalized singular values y
sv_norm{3} = (sv{3})./max((sv{3})); % Normalized singular values z

% Show singular values per tensor dimension
figure ,
subplot(1,3,1),plot((sv{1}./max(sv{1})),'DisplayName','x')
subplot(1,3,2),plot((sv{2}./max(sv{2})),'DisplayName','y')
subplot(1,3,3),plot((sv{3}./max(sv{3})),'DisplayName','z')
legend

nSx = 1:size(U{1},1); % which components are we using x 
nSy = 1:size(U{2},1); % which components are we using y
nSz = 1:5;%1:size(U{3},1); % which components are we using z
UnS{1} = U{1}(:,nSx);
UnS{2} = U{2}(:,nSy);
UnS{3} = U{3}(:,nSz);
SnS    = S(nSx,nSy,nSz);
% Generating filtered data first 
Datafilt =  lmlragen(UnS,SnS); % reconstructing using relevant MLSVD components we desire-- Hard coded components for now for testing. We will ideally find hte best components
%% just for visualization show raw data and Reconstructed dat
arb_frame=10; % what arbituary frame are we visualizing
figure;
subplot(2,1,1)
imagesc(Datafilt(:,:,arb_frame)); colorbar;title(strcat("Filtered img-nsx=",num2str(length(nSx))," nsy=",num2str(length(nSy))," nsz=",num2str(length(nSz))));
subplot(2,1,2)
%imagesc(ff_ROI_image(:,:,arb_frame));colorbar;title("Original Image")
imagesc(interp_ROI_image(:,:,arb_frame));colorbar;title("SPLINED Original Image")
%% After Initial Filtering---Plot prominent frequency vs principal component
% Decompose and look at Z component ( time)
[Uf, Sf, svf] = mlsvd(Datafilt,size(Datafilt)); % post filtering
clear avgROIfilt fourier_MLSVD_comp max_frqs_MLSVD max_amp_MLSVD
for i=1:size(Uf{3},2)
    avgROIfilt(:,i) = (Uf{3}(:,i));
    fourier_MLSVD_comp{i}=Fourier_Representation(fs,ff_time_stamp,avgROIfilt(:,i));
    max_freqs_MLSVD(i)= fourier_MLSVD_comp{i}.freq_max;
    max_amp_MLSVD(i)=fourier_MLSVD_comp{i}.freq_amp_max;
end

figure;subplot(2,1,1);plot(1:size(Uf{3},2),max_freqs_MLSVD);title("Max frequency of MLSVD vs MLSVD comp. #");ylabel("Freq of max amp (fft) (Hz)");xlabel("MLSVD comp")
subplot(2,1,2);plot(1:size(Uf{3},2),max_amp_MLSVD);title("Max AMPLITUDE(fft) of MLSVD vs MLSVD comp. #");ylabel("FFT Amplitude max(counts)");xlabel("MLSVD comp")

%% bandpass relevant MLSVD components and return reconstructed Uf matrix
recon_MLSVD=bandpass_MLSVD(fs,Uf{3},bp_mat);

% comparing prebandpass and postband pass (TIME DOMAIN)
figure;plot(Uf{3}(:,1));hold on
plot(recon_MLSVD.output_signal(:,1));xlabel("time (seconds)");ylabel("Signal Counts")
legend("Prebandpass", strcat("Bandpass-",num2str(bp_mat)))

%% Reconstruct original signal --> Average again --> Time domain--> Fourier again..
nSx_bp = 1:size(Uf{1},1); % which components are we using x 
nSy_bp = 1:size(Uf{2},1); % which components are we using y
nSz_bp = 1:size(Uf{3},1);%1:size(U{3},1); % which components are we using z
UnS_bp{1} = Uf{1}(:,nSx_bp);
UnS_bp{2} = Uf{2}(:,nSy_bp);
UnS_bp{3} = recon_MLSVD.output_signal(:,nSz); % since we only BPed "z" aka time signal
SnS_bp   = Sf(nSx,nSy,nSz);
%% Generating bp+reconstructed data first IN TIME DOMAIN
Datafilt_MLSVD_bp =  lmlragen(UnS_bp,SnS_bp); % reconstructing using relevant MLSVD components we desire-- Hard coded components for now for testing. We will ideally find hte best components
% Visualizing bandpass raw signal
figure;imagesc(Datafilt_MLSVD_bp(:,:,1));colorbar;title(strcat("Bandpass MLSVD-",num2str(bp_mat)));

for i=1:size(Datafilt_MLSVD_bp,3) % mean over ROI
   temp=Datafilt_MLSVD_bp(:,:,i);
   Datafilt_MLSVD_bp_td(i)=mean(temp(:)); % mean over ROI
end
figure;plot(splined_time,Datafilt_MLSVD_bp_td);title("Filtered+Bandpass MLSVD ROI vs time(s)")
%% fourier of filtered MLSVD Data
Fourier_Data_MLSVD_bp=Fourier_Representation(fs,splined_time,Datafilt_MLSVD_bp_td);

figure;
plot(Fourier_Data_MLSVD_bp.freq_fft,Fourier_Data_MLSVD_bp.freq_amp./max(Fourier_Data_MLSVD_bp.freq_amp));title(strcat("NORMALIZED Amplitude vs frequency BP-",num2str(bp_mat)));
hold on
plot(EMD_freqdom_bp.freq_fft,EMD_freqdom_bp.freq_amp./max(EMD_freqdom_bp.freq_amp));xlabel("freq(hz");ylabel("Normalized counts")
legend("MLSVD Analysis","EMD Analysis")
% unnnormalize
figure;
plot(Fourier_Data_MLSVD_bp.freq_fft,Fourier_Data_MLSVD_bp.freq_amp);title(strcat ("NONNORMALIZEDAmplitude vs frequency BP-",num2str(bp_mat)));
hold on
plot(EMD_freqdom_bp.freq_fft,EMD_freqdom_bp.freq_amp);xlabel("freq(hz");ylabel("counts")
legend("MLSVD Analysis","EMD Analysis")




%%
%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SEPARATE STUFF
%% make bandpass 
% % fir 1 uses '
% fn=fs/2; % nyquist sampling--> 15 hz 
% b = fir1(1,[0.8/fn 3.2/fn]);
% Filtered_time_signal=filtfilt(b,1,recon_signal_time_dom);
% figure;
% subplot(2,1,1)
% plot(ff_time_stamp,Filtered_time_signal./recon_signal_time_dom);title("Filters./ Original EMD") % comparing two signals
% subplot(2,1,2);
% plot(ff_time_stamp,Filtered_time_signal);title("Filtered signal") % comparing two signals
% %% FFT bandpassed siganl
% 
% 
% Y2=fft(Filtered_time_signal,n); % frequency response
% % single sided and double sided spectrum
% P4 = abs(Y2/L);
% P3 = P4(1:n/2+1,:);
% P3(:,2:end-1) = 2*P3(:,2:end-1);
% 
% figure;
% freq_fft_filt=(0:(fs/n):(fs/2-fs/n));
% freq_amp_filt=P3(1:n/2);
% plot(freq_fft_filt,freq_amp_filt);xlabel("Frequency(hz)");ylabel("Amplitude");title("FFT bandpass+hamming window")
% %% bandpass ---simple
% 
% bandpass_v2=bandpass(recon_signal_time_dom,[0.8 3.2],fs);
% figure;plot(ff_time_stamp,bandpass_v2);
% % now FFT again..
% Y3=fft(bandpass_v2,n); % frequency response
% % single sided and double sided spectrum
% P6 = abs(Y3/L);
% P5 = P6(1:n/2+1,:);
% P5(:,2:end-1) = 2*P5(:,2:end-1);
% 
% figure;
% freq_fft=(0:(fs/n):(fs/2-fs/n));
% freq_amp_bp=P5(1:n/2);
% plot(freq_fft,freq_amp_bp);xlabel("Frequency(hz)");ylabel("Amplitude");title("FFT bandpass v2 no hamming window")
% 
% 
% %freqz(b,1,512)
% 
% % for i=1:30
% % Image_Frame=py.CameraFunctions.take_IR_image(VideoStreams);
% % Image_Frame_mat=double(Image_Frame);
% % Image_Frame_rs(:,:,i)=reshape(Image_Frame_mat,320,240);
% % %Image_Frame_cell=cell(Image_Frame);
% % %Image_Frame_int=cellfun(@double,Image_Frame_cell);
% % %Image_Frames=reshape(Image_Frame_int,320,240);
% % %matlab_frame(:,:,i)=DEPRECATED_PythonFrametoImage(Image_Frame);
% % end
% % toc
% % figure;
% % imagesc(Image_Frame_rs(:,:,25));colorbar
% 
% %P=cell(Image_Frame);
% %A = cellfun(@uint16,P);
% 
% 
