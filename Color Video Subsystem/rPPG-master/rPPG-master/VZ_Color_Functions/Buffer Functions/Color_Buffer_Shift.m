function  new_buffer_struct=Color_Buffer_Shift(init_buffer,interp_struct)
%% Written on 30NOV21
% 1. Init_buffer: Input buffer
% 2. interp_struct: New Data

% Output: 
% 1. new_buffer_struct: buffer with new data. Remove oldest data, slide and
% insert new data

%Because data is splined to the same frame rate already, sampling rate will
%match
init_dat=init_buffer.resampledYData; % Full initial buffer 
new_dat=interp_struct.resampledYData; % new data

new_length=size(new_dat,1);
temp=circshift(init_dat,-new_length,1); % shifting data
temp(end-(new_length-1):end,:)=new_dat; % replacing the oldest data

new_buffer_struct=init_buffer;
new_buffer_struct.resampledYData=temp; % overwriting with new data






end