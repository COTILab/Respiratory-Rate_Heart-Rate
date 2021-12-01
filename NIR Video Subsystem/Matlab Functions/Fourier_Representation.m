function Fourier_Data=Fourier_Representation(fs,time_stamps,time_signal)
%11SEP21: Returns Fourier Structure of fourier transform with fields
%relevant for plotting/ visualization

% INPUTS: 
%1. fs=sampling frequency in Hz
%2. time_stamps=Time entries in seconds-- This is 
%3. time_singal=counts corresponding to time_stamps



L=max(time_stamps)./(1/fs);
n=2^nextpow2(L);
if n<500
   n=500; % n/2 freqs expected
end

Y=fft(time_signal,n); % frequency response
% single sided and double sided spectrum
P2 = abs(Y/L);
P2=reshape(P2,[1 length(P2)]);
P1 = P2(:,1:n/2+1);
P1(:,2:end-1) = 2*P1(:,2:end-1);

%figure;
freq_fft=(0:(fs/n):(fs/2-fs/n));
freq_amp=P1(1:n/2);

% NO BANDPASSING HERE
% find primary freq component in Hz
[max_val,idx]=max(freq_amp);
Fourier_Data.freq_amp_max=max_val;
Fourier_Data.freq_max=freq_fft(idx); % maximum freq(hz)
Fourier_Data.freq_fft=freq_fft; % frequencies in Hz
Fourier_Data.freq_amp=freq_amp; % amplitude


end