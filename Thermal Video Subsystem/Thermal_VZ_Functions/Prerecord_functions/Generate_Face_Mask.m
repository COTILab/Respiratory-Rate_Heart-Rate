function final_struct=Generate_Face_Mask(raw_struct,roi_fixed)
% mask to face based on fix roi
final_struct=raw_struct;

final_struct.masked_img=raw_struct.images(roi_fixed(2):roi_fixed(2)+roi_fixed(4)...
    ,roi_fixed(1):roi_fixed(1)+roi_fixed(3),:);


end