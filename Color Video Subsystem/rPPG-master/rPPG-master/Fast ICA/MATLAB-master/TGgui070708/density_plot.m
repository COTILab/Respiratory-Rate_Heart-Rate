function density_plot(handles,einzelmat)
    imagefile = get(handles.im_file_edit, 'String');
    outpath = get(handles.out_dir_edit, 'String');
    if outpath(length(outpath))~='\'
        outpath = [outpath,'\'];
    end
    
    %Obtain info on image type, etc
    file_info = get_file_info2(imagefile, handles);

    load(einzelmat,'yf_all','xf_all','x_size','y_size','x_offset','y_offset','total_molecules');
    
    colormap2;
    
    q         = str2double(get(handles.cam_pix_edit,'String')); %expansion factor
    ishift    = str2double(get(handles.ishift,'String'));
    jshift    = str2double(get(handles.jshift,'String'));
    xw_render = str2double(get(handles.xw_render_edit,'String'));
    yw_render = str2double(get(handles.yw_render_edit,'String'));
    maxmol    = str2double(get(handles.maxmol_edit,'String'));
    um_per_pixel = str2double(get(handles.um_per_pixel_edit,'String'));
    
    mfactor=1/um_per_pixel;
    %mfactor=1/(0.1); % gives 0.1 um per pixel
    
    ymin=(y_offset+jshift)*q;
    xmin=(x_offset+ishift)*q;
    
    if xw_render ~= 0
        imax_x=xw_render*q;
    else
        imax_x=x_size*q;
    end
    if yw_render ~= 0
        imax_y=yw_render*q;
    else
        imax_y=y_size*q;
    end
    
    yf_um=yf_all*q;
    xf_um=xf_all*q;  

    npoints=zeros(round(imax_y*mfactor),round(imax_x*mfactor));

    for i=1:total_molecules
        i1=round((yf_um(i)-ymin)*mfactor);
        i2=round((xf_um(i)-xmin)*mfactor);
        if i1>=1 && i2>=1 && i1<=imax_y*mfactor && i2<=imax_x*mfactor
          npoints(i1,i2)=npoints(i1,i2)+1;
        end
    end
    tot_mol_in_plot=sum(sum(npoints));

    npoints_scale=npoints;
    clear npoints;
    npoints_scale=npoints_scale.*(npoints_scale<maxmol)+maxmol.*(npoints_scale>=maxmol);

    figure
    imagesc(npoints_scale);
    title(['Total Molecules in Density Plot:',num2str(tot_mol_in_plot)])
    axis image
    colormap(cmap1);
    colorbar;

    if get(handles.write_image_checkbox,'Value') %write to file if box is checked
        if (file_info.part_name(length(file_info.part_name)) == '_') %Avoid saving with repeat seperators
            wf_sum_file=[outpath,'\',file_info.part_name,num2str(file_info.start),'-',num2str(file_info.stop),'dp.tif'];
        else
            wf_sum_file=[outpath,'\',file_info.part_name,num2str(file_info.start),'-',num2str(file_info.stop),'_dp.tif'];
        end
        imwrite(uint8(npoints_scale),wf_sum_file,'Compression','none');
    end

