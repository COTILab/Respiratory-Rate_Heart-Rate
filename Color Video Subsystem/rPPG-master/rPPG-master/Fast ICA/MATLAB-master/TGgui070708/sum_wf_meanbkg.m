%This program creates mat file of sum of widefield frames and arrays of mean background 
%for background subtraction in einzelreader.m  This code is a hybrid of code taken 
%from sum_widefield_movie5.m and meanbkg_movie5.m.
function [image_sum, field0, n_field, meanbkg_all] = sum_wf_meanbkg(handles)
	imagefile = get(handles.im_file_edit, 'String');
    outpath = get(handles.out_dir_edit, 'String');
    if outpath(length(outpath))~='\'
        outpath = [outpath,'\'];
    end

    % Set up the progress bar
    w = waitbarxmod(0,'Obtaining file info. Please wait...','CreateCancelBtn','delete(gcf)');
    set(w,'Name','Progress Bar');
    uicontrol('Style','pushbutton','Parent',w,'String','Pause','Position',[210,10,60,23], ...
              'UserData',1,'Callback',@pause_gui);
    pause(.1); %Pause to ensure window completes drawing
    drawnow;    %Draw the extra button immediately    
    keepontop('Progress Bar'); %Keep the bar on top of other windows (mex function)

    %Obtain info on image type, etc
    file_info = get_file_info2(imagefile, handles);
    pause(.333); %Pause to avoid flickering
    waitbarxmod(0,w,'Executing "sum wf meanbkg.m" ...');
    
    xw  = file_info.width;
    yw  = file_info.height;
    field0  = file_info.start;
    n_field = file_info.stop;
    
    if get(handles.custom_roi,'Value')
        x_offset   = str2double(get(handles.x_off_edit,'String'));
        y_offset   = str2double(get(handles.y_off_edit,'String'));
        x_size     = str2double(get(handles.x_size_edit,'String'));
        y_size     = str2double(get(handles.y_size_edit,'String'));
    else
        x_offset = 1;
        y_offset = 1;
        x_size   = xw;
        y_size   = yw;
    end

    image_sum = zeros(yw,xw);

    wb_norm = n_field-field0;
    if wb_norm == 0  %Avoid divide by zero errors
        wb_norm = 1;
    end

    zero_level = str2double(get(handles.zero_lvl,'String'));

    if strcmp(file_info.type,'singlepage')      %Type will determine how to load the image
        for fileloop = field0:n_field
            index = num2str(fileloop,file_info.prec);
            infile = [file_info.path,'\',file_info.part_name,index,file_info.ext];
            
            i1 = double(imread(infile))-zero_level;
            i1=i1.*(i1>0); % set any negative pixel values to zero

            image_sum = image_sum + i1;
            meanbkg = mean(mean(i1(y_offset:y_offset+y_size-1,x_offset:x_offset+x_size-1)));
            meanbkg_all(fileloop) = meanbkg;

            waitbarxmod((fileloop-field0)/wb_norm,w); %update
        end     
    elseif strcmp(file_info.type,'multipage')
        for fileloop = field0:n_field
            i1 = double(imread(imagefile,fileloop))-zero_level;
            i1=i1.*(i1>0); % set any negative pixel values to zero
            
            image_sum = image_sum + i1;
            meanbkg = mean(mean(i1(y_offset:y_offset+y_size-1,x_offset:x_offset+x_size-1)));
            meanbkg_all(fileloop) = meanbkg;

            waitbarxmod((fileloop-field0)/wb_norm,w); %update
        end
    end

    delete(w); %Delete the waitbar

%Save Variables
%----------------
    if (file_info.part_name(length(file_info.part_name)) == '_')
        out_file = [outpath,file_info.part_name,'sum_wf_meanbkg_',num2str(field0),'-',num2str(n_field),'.mat'];
    else
        out_file = [outpath,file_info.part_name,'_sum_wf_meanbkg_',num2str(field0),'-',num2str(n_field),'.mat'];
    end

    if ~exist(outpath,'dir') %Make sure the directory exists
        answer = questdlg('Output directory could not be accessed. Choose a new save location?','Warning!','Yes','Discard','Yes');

        if strcmp(answer,'Yes')
            outpath = uigetdir();
            if ~outpath
                return
            end
            if outpath(length(outpath))~='\'
                outpath = [outpath,'\'];
            end

            if (file_info.part_name(length(file_info.part_name)) == '_')
                out_file = [outpath,file_info.part_name,'sum_wf_meanbkg_',num2str(field0),'-',num2str(n_field),'.mat'];
            else
                out_file = [outpath,file_info.part_name,'_sum_wf_meanbkg_',num2str(field0),'-',num2str(n_field),'.mat'];
            end
        else
            return
        end
    end

    list = who; %Use regular expressions to ensure handles are not saved
    match = regexp(list,'^plot|handles|\<h\>|\<w\>');
    for i=length(match):-1:1
        if match{i}
            list(i)=[];
        end
    end
    save(out_file,list{:}); %save mat file
    setappdata(0,'last_mbkg_save',out_file); %Save the mat file path for other functions to use
%----------------