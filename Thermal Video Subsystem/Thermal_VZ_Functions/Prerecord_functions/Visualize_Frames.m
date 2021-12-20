function Visualize_Frames(images,roi_fixed)
figure;
for i=1:size(images,3)
   imagesc(images(:,:,i))
   hold on
   try
   rectangle('Position',roi_fixed)
   catch
   end
   colorbar;
   title(i);
   pause(0.1);
    
    
end


end