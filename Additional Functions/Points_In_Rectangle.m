function reshaped_pts=Points_In_Rectangle(xx,yy,bboxPoints1,bboxPoints2)
%%  Written by Rahul--03SEP21-- Function returns which pixels values are inside of bounding box
% Inputs:
%1. xx=meshgrid points of video
%2  yy=meshgrid points of video -->
%[xx,yy]=meshgrid(size(frame,1),size(frame,2)
% 3. bboxPoints1=edges of bounding box ( dim 2)
% 4. bboxPoints2=edges of bounding box(dim1)

reshaped_pts=reshape(inpolygon(xx(:),yy(:),bboxPoints1,bboxPoints2),size(xx));

end
