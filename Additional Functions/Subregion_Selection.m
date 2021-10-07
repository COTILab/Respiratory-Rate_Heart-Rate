function newBox=Subregion_Selection(bBoxPoints,height_perc,width_perc)
% Written by Rahul Ragunathan --03SEP12
% Function returns new "bounding box" based off subregion of cascade
% detector--> Identifies which region is safe to analyze

%Inputs:
%1.bBoxPoints: Original bounding box matrix. 4x2 matrix for a SINGLE BOUNDING
%BOX --> 4 corners of bounding box
%2. height_perc: What percent do we cut into bounding box. refers to dim 1;
%eg: a value of 0.1 would increase the lower dimension by 10% and DECREASE
%the upper dimension by 10% .
%3. width_perc:what percent do we cut into bounding box. refers to dim 2:
%eg: a value of 0.1 would increase the lower dimension by 10% and DECREASE
%the upper dimension by 10% .

% Outputs;
% newBox: Returns a 4x2 matrix for A SINGLE BOUNDING BOX,that is a
% subregion based on specified parameters

orig_height=max(bBoxPoints(:,1))-min(bBoxPoints(:,1));
orig_width= max(bBoxPoints(:,2))-min(bBoxPoints(:,2));

height_inc=orig_height*height_perc;
width_inc=orig_width*width_perc;

newBox=bBoxPoints; % first copy original dims

newBox(1,:)=newBox(1,:)+[height_inc width_inc]; % low,low corner so we inc both
newBox(2,:)=newBox(2,:)+[-height_inc width_inc];% high,low corner we dec dim 1 and inc dim 2
newBox(3,:)=newBox(3,:)+[-height_inc -width_inc];% high,high corner we dec dim 1 and inc dim 2
newBox(4,:)=newBox(4,:)+[height_inc -width_inc];% low,high corner we dec dim 1 and inc dim 2
end