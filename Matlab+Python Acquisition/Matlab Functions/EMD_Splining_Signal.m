function [Splined_times,Splined_Signal]= EMD_Splining_Signal(fs_est,ROI_vec,ori_time_stamps,Analysis_time)

%% Written on 15SEP21-RR
% input:1 fs_est: estimated Sampling rate. Use this to determine step size
% 2 ROI_vec; Orignal vec to spline
%3. ori_time_stamps: Original time vec
% 4. Analysis_time; How large is our ideal analysis window
Splined_times=min(ori_time_stamps):(1/fs_est):max(ori_time_stamps);%linspace(0,Analysis_time,length(ROI_vec));%%+min(ori_time_stamps);
Splined_Signal=interp1(ori_time_stamps,ROI_vec,Splined_times);%ROI_vec;%;

%Splined_times=linspace(0,Analysis_time,length(ROI_vec));%%+min(ori_time_stamps);
%Splined_Signal=ROI_vec;%
%disp("TESTING NO SPLINING-- JUST MODIFYING TIME STAMPS")

end%