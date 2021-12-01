function [Analyzed_fourier,freq,amp]=Frequency_Domain_EMD_Reconstruction(inp_signal,time_entries,fs,title_strs)
for i=1:length(inp_signal) % assumes inp_signal is a cell array
    try
    Analyzed_fourier{i}=Fourier_Representation(fs,time_entries,inp_signal{i}); % with bandpass
    catch
         Analyzed_fourier{i}=Fourier_Representation(fs,time_entries,inp_signal{i}{1}); % with bandpass
    end
freq{i}=Analyzed_fourier{i}.freq_fft;
amp{i}=Analyzed_fourier{i}.freq_amp;
    
    
end
Plotting_Mult_Arrays(freq{1},amp,title_strs)



end
%Analyzed_fourier{rr}=Fourier_Representation(image_struct_first.fs_est,new_time_stamps,filtered_recon{rr}); % with bandpass