function [recon_signal,imf,info,residual,imf_idx_roi1_1,imf_idx_roi1_2,title_strs]=Time_Domain_EMD_Reconstruction(time_entries,Raw_dat,upper_IMF)
%% Generates reconstructions for 1 ROI at a time FOR SIMPLICITY
% Sweeps the summation of IMF 1 : UpperIMF
%disp("WITHOUT SPLINING")
% Get IMF Mats
recon_signal{1}=Raw_dat;
title_strs{1}="Raw Data NO EMD";
for i=1:upper_IMF
    imf_mat{1}=[i,upper_IMF];
    title_strs{i+1}=strcat("EMD=[",num2str(imf_mat{1}(1)),",",num2str(imf_mat{1}(2)),"]");
    [recon_signal{i+1},imf{i},info{i},residual{i},imf_idx_roi1_1{i},imf_idx_roi1_2{i}]=  EMD_Analysis_MULTIPLEROIS(Raw_dat,imf_mat);%disp("WITHOUT SPLINING")
    
    
end


Plotting_Mult_Arrays(time_entries,recon_signal,title_strs)
%% % removing raw data entry now we have plotted it

%recon_signal{1}=[]; 
%recon_signal=recon_signal(~cellfun('isempty',recon_signal));




end