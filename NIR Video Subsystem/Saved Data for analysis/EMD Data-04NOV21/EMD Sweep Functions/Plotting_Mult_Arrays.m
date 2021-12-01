function Plotting_Mult_Arrays(x_inp,cell_inp,varargin)
if length(varargin)==1
   title_strs=varargin{1};
    
end


nrows=1;
ncols=length(cell_inp);

figure;
for i=1:ncols
    try
        subplot(nrows,ncols,i);plot(x_inp,cell_inp{i})
    catch
        subplot(nrows,ncols,i);plot(x_inp,cell_inp{i}{1});
    end
    if exist('title_strs')
    title(strcat(title_strs{i}))    
        
    else
    title(strcat("ROI-",num2str(i)))
    end
    
    
end


end