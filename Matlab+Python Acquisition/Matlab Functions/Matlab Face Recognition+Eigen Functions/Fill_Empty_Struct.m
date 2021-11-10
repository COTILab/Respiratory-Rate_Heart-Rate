function Final_Struct=Fill_Empty_Struct(images,inp_struct) 
%% Written on 25OCT21  
%%Input:
%  1. Images: input of images. Only needed to know how many ROIs/ empty
%  struct positions need to be filled
% 2 inp_struct: Input struct to fill
temp=inp_struct{1};
for i=1:size(images,3)
    if length(inp_struct)<i
       inp_struct{i}=temp; 
    end
    if length(inp_struct{i})
        temp=inp_struct{i};
    end
    Final_Struct{i}=temp;
    

end
end