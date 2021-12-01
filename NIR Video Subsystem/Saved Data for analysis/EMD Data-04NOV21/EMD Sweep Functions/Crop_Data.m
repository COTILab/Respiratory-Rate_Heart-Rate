function New_Data=Crop_Data(Raw_dat,clip_idx)
%1. Raw_dat: Cell array. Raw Data col vector for each Region of interest
%that we choose to evalute
%2. clip_idx: Which FRAMES do we want to use: 2 element vector (first
%frame,last_frame)
% Crop data in order to evaluate the effect of window length on SNR and
% signal decomposition.
for i=1:length(Raw_dat) % moving across ROIs
    temp=Raw_dat{1};
    New_Data{i}=temp(clip_idx(1):clip_idx(2));
    
    
end

end