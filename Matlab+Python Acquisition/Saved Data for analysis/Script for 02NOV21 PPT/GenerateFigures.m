close all
clear all 
clc

Fixed_RR=28; % breaths per minute Metronome data from OCT0621 -- Manual ROI Selection
PulseOx_HR_avg=55.15; % See OxyCare-2021-10-06_11-48-39.xls file for derivation
PulseOx_HR_std=3.20;% See OxyCare-2021-10-06_11-48-39.xls file for derivation
%% Importing necessary data
HR_RR_dat=importdata('Output_HRTest_28RespRate.mat');
img_dat=importdata('FaceChestImg_02NOV21.mat');
fourier_dat=importdata('FaceChestFourier_02NOV21.mat');

%% Our system statistcs
avg_HR=round(mean(HR_RR_dat.hr{1}),0);
std_HR=round(std(HR_RR_dat.hr{1},0,2),0);

avg_RR=round(mean(HR_RR_dat.hr{2}),0);
std_RR=round(std(HR_RR_dat.hr{2},0,2),2);
%% Generating plot
nrows=2;
ncols=2;
figure
subplot(nrows,ncols,1);
imagesc(img_dat{1});colorbar;title("Face Image-Heart Rate Input")

%%
subplot(nrows,ncols,2); % HR plot
adj_time=HR_RR_dat.tp{1}-min(HR_RR_dat.tp{1});
plot(adj_time,HR_RR_dat.hr{1},'b*')
hold on
plot(adj_time,repmat(avg_HR,1,length(HR_RR_dat.tp{1})),'b-')
plot(adj_time,repmat(avg_HR-std_HR,1,length(HR_RR_dat.tp{1})),'b--')
plot(adj_time,repmat(avg_HR+std_HR,1,length(HR_RR_dat.tp{1})),'b--')
% Plot Pulse ox values
plot(adj_time,repmat(PulseOx_HR_avg,1,length(HR_RR_dat.tp{1})),'m-')
plot(adj_time,repmat(PulseOx_HR_avg-PulseOx_HR_std,1,length(HR_RR_dat.tp{1})),'m--')
plot(adj_time,repmat(PulseOx_HR_avg+PulseOx_HR_std,1,length(HR_RR_dat.tp{1})),'m--')

xlim([min(adj_time),max(adj_time)])
legend('Noncontact HR Data','Noncontact Avg+stdev','','','Pulse Ox Avg+Stdev')
title("Heart Rate: Our System vs Commercial Pulse Ox ")
ylabel("Heart Rate (Beats per Minute)")
xlabel("Time(seconds)")
%%
subplot(nrows,ncols,3);
imagesc(img_dat{2});colorbar;title("Chest Image-Respiratory Rate Input")
%%
subplot(nrows,ncols,4); % RR plot
adj_time=HR_RR_dat.tp{2}-min(HR_RR_dat.tp{2});
plot(adj_time,HR_RR_dat.hr{2},'b*')
hold on
plot(adj_time,repmat(avg_RR,1,length(HR_RR_dat.tp{1})),'b-')
plot(adj_time,repmat(avg_RR-std_RR,1,length(HR_RR_dat.tp{1})),'b--')
plot(adj_time,repmat(avg_RR+std_RR,1,length(HR_RR_dat.tp{1})),'b--')
% Plot Pulse ox values
plot(adj_time,repmat(Fixed_RR,1,length(HR_RR_dat.tp{1})),'m-')


xlim([min(adj_time),max(adj_time)])
ylim([25 30]);
legend('Noncontact RR Data','Noncontact Avg+stdev','','','Metronome Fixed Respiratory Rate')
title("Respiratory Rate: Our System vs Fixed Breathing Rate")
ylabel("Respiratory Rate (Breathes per Minute)")
xlabel("Time(seconds)")


