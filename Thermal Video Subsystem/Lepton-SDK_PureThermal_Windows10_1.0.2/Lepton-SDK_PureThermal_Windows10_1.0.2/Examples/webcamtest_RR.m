

%% added by RR
close all
clc
clear all
imaqreset

%% end added by RR
info = imaqhwinfo('winvideo', 1);
info.SupportedFormats
form=info.SupportedFormats{4};

%%
% Typically you want y16
delay_amt=1;
pause(delay_amt)
inp = videoinput('winvideo', 1, form);
%frame = getsnapshot(inp);

%%
% Here's a 3d whatever it's called



%[X,Y] = meshgrid(1:size(frame, 2), 1:size(frame, 1));
%figure
%msh = mesh(X, Y, frame);

%%
% loop over this again and again
% creating a live temperature model
%figure
%nrows=2;
%ncols=1;
 t_in=tic;
for x =0:300
   
   delete(inp)
   pause(delay_amt)
   inp = videoinput('winvideo', 1, form);
   %frame = getsnapshot(inp);
   clear frame
    pause(delay_amt)
    
    x
    %
    %t_out(x+1)=toc(t_in);
    %set(msh, "ZData", frame) %% COMMENTED OUT BY RR
    %subplot(nrows,ncols,1);
    %imagesc(frame);
    %title(x)
    
   % subplot(nrows,ncols,2);
   % hold on
    %scatter(t_out(end),mean(frame(:)));
    %title("Mean Img vs time")
end