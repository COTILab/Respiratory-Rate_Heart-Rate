function [skinDetection_out,faceIm,skinImB_3] = selectFaceTemplateStatistics(skinDetection, Im) 
%% Written by Rahul 
%% Returns mask based on hardcoded statistical criterion to try and remove as much outlying pixels as possible
%% Output:
% 1 skinDetection_out: Returns input skinDetection Structure straight back
% 2. faceIm; Cropped image to face-- NO MASK and it returns a double? it
% returns a double?? 
% 3. skinImB_3; Binary mask to apply

skinDetection_out=skinDetection;

xyCoor = round([min(skinDetection.bboxPolygon(1:2:end)) min(skinDetection.bboxPolygon(2:2:end)) max(skinDetection.bboxPolygon(1:2:end)) max(skinDetection.bboxPolygon(2:2:end))]);
xyCoor(xyCoor<1) = 1;

if length(size(Im)) == 3
    faceIm = Im(xyCoor(2):xyCoor(4),xyCoor(1):xyCoor(3),:);
else
    faceIm = Im(xyCoor(2):xyCoor(4),xyCoor(1):xyCoor(3));
end
pctl_range=[30 70]; % percentile range
I=rgb2gray(faceIm); % gray scale to max
min_val=prctile(I(:),pctl_range(1)); % lowest
max_val=prctile(I(:),pctl_range(2)); % highest
% get mask
  
  %temp(temp<=tempFWHM/2)=NaN;


% skinImB_3=I;
% idx_1=(skinImB_3>=min_val);
% idx_2=(skinImB_3<=max_val);
% idx_3=idx_1&idx_2;
% skinImB_3(idx_3)=1; 
% skinImB_3(~idx_3)=0;
% skinImB_3=logical(skinImB_3);
%% FWHM Testing
tempFWHM=nanmedian(I(:));
skinImB_3=I;
idx_1=(skinImB_3<=tempFWHM/2);
idx_2=~idx_1;
skinImB_3(idx_1)=0;
skinImB_3(idx_2)=1;
skinImB_3=logical(skinImB_3);

%%
skinImB_3(:,:,2)=skinImB_3(:,:,1);
skinImB_3(:,:,3)=skinImB_3(:,:,1);
end