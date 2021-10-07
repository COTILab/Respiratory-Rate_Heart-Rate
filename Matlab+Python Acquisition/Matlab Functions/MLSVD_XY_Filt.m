function out_image_struct=MLSVD_XY_Filt(inp_image_struct,vf)
% vf is factor explaining how much of variation we want to include; 0 to 1 value
tic
out_image_struct=inp_image_struct;
disp("MLSVD FILTERING")


[U, S, sv] = mlsvd(double(inp_image_struct.images),size(inp_image_struct.images)); % original




sv_norm{1} = (sv{1})./max((sv{1})); % Normalized singular values x
sv_norm{2} = (sv{2})./max((sv{2})); % Normalized singular values y
sv_norm{3} = (sv{3})./max((sv{3})); % Normalized singular values z

vf2=1-vf; % convrting value
[sv1_m,sv1_i]=min(abs(vf2-sv_norm{1})); % find closest index
[sv2_m,sv2_i]=min(abs(vf2-sv_norm{2})); % find closest index


nSx = 1:sv1_i; % which components are we using x 
nSy = 1:sv2_i; % which components are we using y
nSz = 1:size(U{3},1);%Use all Z

UnS{1} = U{1}(:,nSx);
UnS{2} = U{2}(:,nSy);
UnS{3} = U{3}(:,nSz);
SnS    = S(nSx,nSy,nSz);

Datafilt =  lmlragen(UnS,SnS);
out_image_struct.raw_img_NOMLSVD=out_image_struct.images; % just storing for later
out_image_struct.images=Datafilt;
out_image_struct.MLSVD_time=toc;


% Show singular values per tensor dimension-- VISUALIZATIOn
%figure ,
%subplot(1,3,1),plot((sv{1}./max(sv{1})),'DisplayName','x')
%subplot(1,3,2),plot((sv{2}./max(sv{2})),'DisplayName','y')
%subplot(1,3,3),plot((sv{3}./max(sv{3})),'DisplayName','z')
%legend

end