function out_struct=Correlation_Masking(inp_img)
fs=9; % 9 hz frame rate
time_f=[0:1/fs:(1/fs)*(size(inp_img,3)-1)];
%for k=1:size(inp_img,3) % each frame
    for j=1:size(inp_img,2) % each col
        for i=1:size(inp_img,1) % each row 
            temp=squeeze(inp_img(i,j,:));
            [r, lags]=xcorr(temp);
            cor_sig{i,j}=r;
            cor_lag{i,j}=lags;
            raw_sig{i,j}=temp;
            temp_mean_corr{i,j}=temp-mean(temp(:));
            Fourier_struct{i,j}=Fourier_Representation(fs,time_f,temp_mean_corr{i,j});
            
            
        end
    end
%end
          

out_struct=NaN;


end