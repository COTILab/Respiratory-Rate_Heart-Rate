function Visualize_Statistics_Mask(varargin)
% Visualize sets of images simultaneously
nrows=length(varargin);
ncols=1;
figure
for i=1:size(varargin{1},3) % every frame
    for j=1:length(varargin) % for however many varargin we have
        subplot(nrows,ncols,j)
        imagesc(varargin{j}(:,:,i));colorbar
        title(i);
        
        
        
        
    end
    pause(0.04)
    
end




end