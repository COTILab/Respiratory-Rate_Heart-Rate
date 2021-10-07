function returned_image=DEPRECATED_PythonFrametoImage(Image_Frame)
frame_dim1=length(Image_Frame);

for i=1:frame_dim1 
    temp=Image_Frame{i}; % ith entry of list
    temp_cell=cell(temp);
    temp_arr=cellfun(@double,temp_cell);
    returned_image(i,:)=temp_arr;
    
    
    
end




end