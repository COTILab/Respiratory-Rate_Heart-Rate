function Bbox= Manual_ROI_Selection_MULTIPLEROIS(image,varargin)
% Function written on SEP21

% Allows user to draw ROI Rectangle on image and converts to actual dim
% cutoffs
num_bbox=1;
if ~isempty(varargin)
    num_bbox=varargin{1};
end

for i=1:num_bbox % for evry bbox

figure;
subplot(2,1,1)
%imagesc(image(:,:,end));colorbar
imagesc(log(abs(double(image(:,:,end)))));colorbar

roi=drawrectangle;
roi=round(roi.Position);

ROI_dim1_start=roi(2);%100;;%85;%126;
ROI_dim1_end=roi(2)+roi(4);%182;%144;
ROI_dim2_start=roi(1);%136;%86;%161;
ROI_dim2_end=roi(1)+roi(3);%193;%183;%176;

subplot(2,1,2)
imagesc(image(ROI_dim1_start:ROI_dim1_end,ROI_dim2_start:ROI_dim2_end,end));
colorbar

title(strcat("ROI #",num2str(i)));
Bbox{i}=roi;

end
end