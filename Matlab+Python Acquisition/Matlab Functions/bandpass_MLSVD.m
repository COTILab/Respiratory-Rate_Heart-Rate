function recon_struct=bandpass_MLSVD(fs,orig_data,bandpass_range)
%% returns bandpass signal for every dim of MLSVD
% Date written:13SEP21 -RR
%% INPUT:
% 1. fs: Sampling frequency that signal is acquired at in Hertz. Asssume
% signal is splined to fs
% 2. orig_data: Original MLSVD signal. mxm square matrix.
% 3 .bandpass_range: 1 by 2 matrix--> [Low High] Hertz


%% Output:
% recon_struct: with following fields:
    %1. output_signal: Signal returned in TIME DOMAIN (seconds)
    t_s=tic; % start 
    for i=1:size(orig_data,2) 
       temp=double(orig_data(:,i));
       try
       temp_new_signal=bandpass(temp,[bandpass_range(1) bandpass_range(2)],fs);
       catch
       disp("Running low pass because freq cut off was 0")
       temp_new_signal= lowpass(temp,bandpass_range(2),fs);
       end
       filt_signal(:,i)=double(temp_new_signal);                
    end
    %% adding to final struct
    
    recon_struct.output_signal=filt_signal; % signal in time domain(seconds)
    recon_struct.t_end=toc(t_s);

end