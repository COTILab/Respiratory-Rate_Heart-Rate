close all 
clear all
clc
%% Goal is to understand which IMFs to use and their effect on the reconstructed signal
Data_Path=addpath(genpath('./25 inches from camera- 30 second'));
Full_function_path=addpath(genpath('C:\Users\rahul\OneDrive - Northeastern University\Respiratory Rate_Heart Rate\Matlab+Python Acquisition'));disp("NOTE HARD CODED PATH FOR NOW")

EMD_Function_Path=addpath(genpath('./EMD Sweep Functions'));
%% Load data
clipped_flag=1; %% DO WE WANT TO CLIP OUR DATA SET?
Raw_dat=importdata('Raw_Data.mat'); % Cell entry 1 is HR (face) cel entry 2 is RR(chest)
Nonclipped_Raw_dat=Raw_dat; % just keeping for debuggging 
fs=7.5; 
if clipped_flag==1 % We are clipping
   clip_idx=[100 225]; % First Frame, Last Frame
   Raw_dat=Crop_Data(Raw_dat,clip_idx);
   disp("CLIPPING OUR DATA SET")
    
end

time_entries=linspace(0,(length(Raw_dat{1})-1)*(fs/60),length(Raw_dat{1}));
%% Plotting time domain for visualization
Plotting_Mult_Arrays(time_entries,Raw_dat)
sgtitle("Raw Data-Time Domain")
%% EMD Sweeping Plotting reconstructions TIME DOMAIN
% First we need how many imfs we even have 
imf_mat{1}=[1 NaN];imf_mat{2}=[1 NaN];
[recon_signal,imf,info,residual,imf_idx_1,totalIMF_2]=  EMD_Analysis_MULTIPLEROIS(Raw_dat,imf_mat);disp("WITHOUT SPLINING")
% Get IMF Mats
IMF_mat_roi1=1:1:totalIMF_2{1};
IMF_mat_roi2=1:1:totalIMF_2{2};
%% HR First EMD Time Domain
upper_IMF_HR=length(IMF_mat_roi1); % sweep to this term
%clear imf_mat
ROI1_raw_dat{1}=Raw_dat{1};
[recon_signal_HR,imf_HR,info_HR,residual_HR,imf_idx_roi1_1_HR,imf_idx_roi1_2_HR,title_strs_HR]=Time_Domain_EMD_Reconstruction(time_entries,ROI1_raw_dat,upper_IMF_HR);
sgtitle("EMD-Heart Rate Time Domain")
%for i=1:length(IMF_mat_roi1)
%    imf_mat{1}=[i,upper_IMF];
%    title_strs{i}=strcat("EMD=[",num2str(imf_mat{1}(1)),",",num2str(imf_mat{1}(2)),"]");
%[recon_signal_roi1{i},imf,info,residual,imf_idx_roi1_1,imf_idx_roi1_2]=  EMD_Analysis_MULTIPLEROIS(ROI1_raw_dat,imf_mat);%disp("WITHOUT SPLINING")
%% RR EMD Time Domain
upper_IMF_RR=length(IMF_mat_roi2); % sweep to this term
%clear imf_mat
ROI2_raw_dat{1}=Raw_dat{2}; % Respiratory Rate
[recon_signal_RR,imf_RR,info_RR,residual_RR,imf_idx_roi2_1_RR,imf_idx_roi2_2_RR,title_strs_RR]=Time_Domain_EMD_Reconstruction(time_entries,ROI2_raw_dat,upper_IMF_RR);
sgtitle("EMD-Respiratory Rate Time Domain")
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now we shift to frequency domain WITHOUT ANY SORT OF BANDPASS FILTER
%% HR Frequency Domains
[Analyzed_fourier_HR_NF,freq_HR_NF,amp_HR_NF]=Frequency_Domain_EMD_Reconstruction(recon_signal_HR,time_entries,fs,title_strs_HR);
sgtitle("EMD-Heart Rate Frequency Domain")
%% RR Frequency Domains
[Analyzed_fourier_RR_NF,freq_RR_NF,amp_RR_NF]=Frequency_Domain_EMD_Reconstruction(recon_signal_RR,time_entries,fs,title_strs_RR);
sgtitle("EMD-Respiratory Rate Frequency Domain")
%% Bandpass design
bp_mat{1}=[0.6 3.5];bp_mat{2}=[0.1 0.8]; % PER BOUNDING BOX
%figure
nrows=2;
ncols=1;
title_strs_bp=["Heart Rate BandpassFilter", "Respiratory Rate BandpassFilter"];
for i=1:length(bp_mat)
    % Use estimated frame rate here
    Wn{i}=(2/fs).*bp_mat{i}; % normalize freqs-- based on nyquist
    n{i}=127; % how any points on hamming window and the order
    b{i}=fir1(n{i},Wn{i},hamming(n{i}+1));
    %ax=subplot(nrows,ncols,i);
    %% VISUALIZING THE BANDPASS FILTER HERE
    
    fvtool(b{i},1,'Fs',fs) % visualizing bandpass
    title(title_strs_bp(i))
end
%% APPLYING BANDPASS--> Time Domain--> Back to Frequency Domain (FINAL SIGNAL)
%%%%%%% % % % 
%% Filtering Signals--Time Domain
%% HR
filter_HR=b{1};
Filtered_time_out_response_HR=Filtering_Signals(recon_signal_HR,time_entries,filter_HR,title_strs_HR);
sgtitle(strcat("EMD-Heart Rate Time Domain-bp=",num2str(bp_mat{1})));
%% RR
filter_RR=b{2};
Filtered_time_out_response_RR=Filtering_Signals(recon_signal_RR,time_entries,filter_RR,title_strs_RR);
sgtitle(strcat("EMD-Respiratory Rate Time Domain-bp=",num2str(bp_mat{2})));

%% Converting back to Frequency Domain
%%%%%%%%%%%%%%
%% HR Frequency Domains
[Analyzed_fourier_HR_BP,freq_HR_BP,amp_HR_BP]=Frequency_Domain_EMD_Reconstruction(Filtered_time_out_response_HR,time_entries,fs,title_strs_HR);
sgtitle(strcat("EMD-Heart Rate Frequency Domain-bp=",num2str(bp_mat{1})));
%% RR Frequency Domains
[Analyzed_fourier_RR_BP,freq_RR_BP,amp_RR_BP]=Frequency_Domain_EMD_Reconstruction(Filtered_time_out_response_RR,time_entries,fs,title_strs_RR);
sgtitle(strcat("EMD-Respiratory Rate Frequency Domain-bp=",num2str(bp_mat{2})));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Mostly debugging
%% I want to look at the frequency response
HR_imfs=imf{1}; % removes cell component for simplicity 
RR_imfs=imf{2};

 %filtered_recon{rr}=filter(b{rr},1,recon_signal{rr}); % APPLYING FILTER




%end


%Plotting_Mult_Arrays(time_entries,recon_signal_roi1,title_strs)

