function sum_wf(handles,einzelmat)
    imagefile = get(handles.im_file_edit, 'String');
    outpath = get(handles.out_dir_edit, 'String');
    if outpath(length(outpath))~='\'
        outpath = [outpath,'\'];
    end
    
    %Obtain info on image type, etc
    file_info = get_file_info2(imagefile, handles);

    load(einzelmat,'image_sum','x_size','y_size','x_offset','y_offset');
    
    exf       = str2double(get(handles.exf_edit,'String')); %expansion factor
    ishift     = str2double(get(handles.ishift,'String'));
    jshift     = str2double(get(handles.jshift,'String'));
    xw_render = str2double(get(handles.xw_render_edit,'String'));
    yw_render = str2double(get(handles.yw_render_edit,'String'));
    
    if xw_render ~= 0
        xw=xw_render;
    else
        xw=x_size;
    end
    if yw_render ~= 0
        yw=yw_render;
    else
        yw=y_size;
    end

    x_off=x_offset+ishift;
    y_off=y_offset+jshift;
    
    wf_sum=zeros(yw,xw);
    wf_sum=image_sum(y_off:y_off+yw-1,x_off:x_off+xw-1);
    wf_sum=wf_sum/max(max(wf_sum));
    wf_sum=wf_sum/max(max(wf_sum));
    
    imex=zeros(yw*exf,xw*exf);
    for j=1:yw
        for i=1:xw
            x0=(i-1)*exf+1;
            x1=x0+exf-1;
            y0=(j-1)*exf+1;
            y1=y0+exf-1;
            imex(y0:y1,x0:x1)=wf_sum(j,i);
        end
    end

    figure
    imagesc(imex)
    title(['Expanded Widefield Sum: Frames: ',num2str(file_info.start),'-',num2str(file_info.stop)])
    colormap gray
    axis image

    if get(handles.write_image_checkbox,'Value') %write to file if box is checked
        if (file_info.part_name(length(file_info.part_name)) == '_') %Avoid saving with repeat seperators
            wf_sum_file=[outpath,'\',file_info.part_name,num2str(file_info.start),'-',num2str(file_info.stop),'exp',num2str(exf),'_wf.tif'];
        else
            wf_sum_file=[outpath,'\',file_info.part_name,num2str(file_info.start),'-',num2str(file_info.stop),'_exp',num2str(exf),'_wf.tif'];
        end
        imwrite(uint8(imex*255),wf_sum_file,'Compression','none');
    end
