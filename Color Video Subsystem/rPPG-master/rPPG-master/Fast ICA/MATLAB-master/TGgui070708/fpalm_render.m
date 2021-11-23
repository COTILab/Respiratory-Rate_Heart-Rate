function fpalm_render(handles, h)
    outpath = get(handles.out_dir_edit, 'String'); %load output path from the edit box
    if outpath(length(outpath))~='\'
        outpath = [outpath,'\'];
    end

    mat_file = getappdata(0,'temp_runtime');

    warning off MATLAB:load:variableNotFound    %No need to warn if one isnt found, this is taken care of below
                                                %In addition, depending on
                                                %what calls this function, some of these variables may not yet exist anyway
    load(mat_file,'xf_all','yf_all','r0_all','r0_err_all','total_molecules','file_info',...
                  'w','preview','plot1','x_size','y_size','iprod_thresh',...
                  'threshold','upper_threshold','n_bright_pixel_threshold', ...
                  'max_pixels_above_threshold','base_name','lp','N','a0_all','a0_err_all',...
                  'xf_err_all', 'yf_err_all');
    warning on MATLAB:load:variableNotFound     %Return warning to its original state

%---------------
%Added for backward compatability (changes in naming mechanism)
    if exist('file_info','var')
        if ~isfield(file_info,'part_name')
            load(mat_file,'base_name');
            file_info.part_name = base_name;
        end

        if ~isfield(file_info,'start')
            load(mat_file,'n_start');
            file_info.start = n_start;
        end

        if ~isfield(file_info,'stop')
            load(mat_file,'n_end');
            file_info.stop = n_end;
        end
    else
            load(mat_file,'base_name','n_end','n_start');
            file_info.part_name = base_name;
            file_info.start = n_start;
            file_info.stop = n_end;
    end
%----------------

    if isappdata(0,'from_mat_file')   %If not being called by einzelreader.m, create new waitbar instead of updating
        preview = 0;
        w = waitbarxmod(0,'Executing "fpalm render.m" ...','CreateCancelBtn','delete(gcf)');
        set(w,'Name','Progress Bar');
        uicontrol('Style','pushbutton','Parent',w,'String','Pause','Position',[210,10,60,23], ...
                  'UserData',1,'Callback',@pause_gui);
        pause(.1); %Pause to ensure window completes drawing
        drawnow;    %Draw the extra button immediately        
        %keepontop('Progress Bar');
    else
        waitbarxmod(0,w,'Executing "fpalm render.m" ...');   %rename the waitbar
    end

    if ~exist('total_molecules','var') && preview  %If einzelreader.m hasn't found anything, return with no calculations
        return
    elseif ~exist('total_molecules','var') && ~preview
        delete(w);
        error('No molecules found.');
    end

    sb     = get(handles.sb,'Value');
    sbloc  = str2num(get(handles.sb_loc,'String')); %str2num must be used here, nonscalar
    x0_bar = sbloc(1); %coordinates of scale bar
    y0_bar = sbloc(2);

    q      = str2double(get(handles.cam_pix_edit,'String'));  % pixel size in microns
    exf    = str2double(get(handles.exf_edit,'String')); %expansion factor

    ishift     = str2double(get(handles.ishift,'String'));
    jshift     = str2double(get(handles.jshift,'String'));
    xw_render = str2double(get(handles.xw_render_edit,'String'));
    yw_render = str2double(get(handles.yw_render_edit,'String'));
    fr_un=str2double(get(handles.frac_unc,'String'))/100;
    max_unc=str2double(get(handles.max_unc,'String'))/q; %convert to pixels
    r0_tol_min = str2double(get(handles.r0_tol_min,'String'));
    r0_tol_max = str2double(get(handles.r0_tol_max,'String'));
    lp_tol_min = str2double(get(handles.lp_tol_min,'String'));
    lp_tol_max = str2double(get(handles.lp_tol_max,'String'));
    N_tol_min = str2double(get(handles.N_tol_min,'String'));
    N_tol_max = str2double(get(handles.N_tol_max,'String'));
    use_lp   = get(handles.lp_N_cb,'Value');
    
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
    
    if(~exist('lp','var'))
        load(mat_file,'rbox');
        NA     = str2double(get(handles.NA,'String'));
        wvlnth = str2double(get(handles.wvlnth,'String'))/1000; %Conversion to um
        psf_scale = str2double(get(handles.psf_scale_edit,'String'));
        ppp    = str2double(get(handles.pix_to_pho,'String'));
        bkgn   = str2double(get(handles.bkgn_noise,'String'));

        r0 = psf_scale*0.55*wvlnth/NA/1.17; % 1/e2 radius of PSF, use 1/e2 = FWHM/1.17 from Pawley
                                      % scaled (20% for "real objective" due to
                                      % measured PSF from Hess and Webb 2002)
        psf_std=r0/2; %standard deviation of psf
        
        r0pix=r0/q; %1/e^2 radius of psf in pixels
        psf_w02=r0pix*r0pix;
        [xpix,ypix] = meshgrid(-rbox:rbox,-rbox:rbox);
        yfit=exp(-2*((xpix).*(xpix)+(ypix).*(ypix))/psf_w02);
        npix=sum(sum(yfit));     % area of molecule in square pixels

        a0_phot=a0_all/ppp;    % peak amplitude of each molecule in photons
        N=npix*a0_phot;        % number of photons for each molecule

        lp2=((psf_std^2)+(q^2)/12)*1./N+8*pi*(psf_std^4)*(bkgn^2)/(q^2)*1./(N.*N);
        lp=sqrt(lp2); 
    end

    lppix=lp/q*exf;   % width of each molecule in pixels, based on localization-uncertainty 
    lp2pix=lppix.*lppix;
        
    xf=exf*(xf_all-ishift-0.5);
    yf=exf*(yf_all-jshift-0.5);
    xc=uint16(xf);
    yc=uint16(yf);

    nstart=1;
    nend=total_molecules;
    if exist('xf_err_all','var') %check to see if error estimates exist, for backward compatibilty
        render_func_w_tol;
    else
        render_func;
    end

    maxintens=max(max(impts));
    impts = impts/maxintens;
   
    if sb %draw scale bar if selected
        um1=1/q*exf;
        um1_round=round(um1);
        bar_width=12;

        for i=1:um1_round
            for j=1:bar_width
                xi=i+x0_bar;
                yi=j+y0_bar;
                impts(yi,xi)=1;
            end
        end

        nm250=0.25/q*exf;
        nm250_round=round(nm250);
        bar_width=4;
        y0_bar=y0_bar+bar_width;

        for i=1:um1_round
            for j=1:bar_width
                ival=round(i/nm250_round);
                ival=mod(ival,2);

                xi=i+x0_bar;
                yi=j+y0_bar;
                impts(yi,xi)=double(ival);
            end
        end
    end

    figure('Name','FPALM Image');
    imagesc(impts)
    colormap gray
    axis image;
    title(['FPALM Image: Rendered/Total Molecules:',num2str(n_rendered),'/',num2str(total_molecules)])
    delete(w);

    if get(handles.write_image_checkbox,'Value') %write to file if box is checked
        if (file_info.part_name(length(file_info.part_name)) == '_') %Avoid saving with repeat seperators
            if get(handles.adv_cb,'Value')
                impts_gray_file=[outpath,'\',file_info.part_name,'pts_',num2str(file_info.start),'-',num2str(file_info.stop),'_t',num2str(iprod_thresh),'-',num2str(threshold),'-',num2str(upper_threshold),'_npt',num2str(n_bright_pixel_threshold),'-',num2str(max_pixels_above_threshold),'_e',num2str(exf),'.tif'];
                render_prop_file=[outpath,'\',file_info.part_name,'pts_',num2str(file_info.start),'-',num2str(file_info.stop),'_t',num2str(iprod_thresh),'-',num2str(threshold),'-',num2str(upper_threshold),'_npt',num2str(n_bright_pixel_threshold),'-',num2str(max_pixels_above_threshold),'_e',num2str(exf),'.mat'];
            else
                impts_gray_file=[outpath,'\',file_info.part_name,'pts_',num2str(file_info.start),'-',num2str(file_info.stop),'_t',num2str(iprod_thresh),'_e',num2str(exf),'.tif'];
                render_prop_file=[outpath,'\',file_info.part_name,'pts_',num2str(file_info.start),'-',num2str(file_info.stop),'_t',num2str(iprod_thresh),'_e',num2str(exf),'.mat'];
            end
        else
            if get(handles.adv_cb,'Value')
                impts_gray_file=[outpath,'\',file_info.part_name,'_pts_',num2str(file_info.start),'-',num2str(file_info.stop),'_t',num2str(iprod_thresh),'-',num2str(threshold),'-',num2str(upper_threshold),'_npt',num2str(n_bright_pixel_threshold),'-',num2str(max_pixels_above_threshold),'_e',num2str(exf),'.tif'];
                render_prop_file=[outpath,'\',file_info.part_name,'_pts_',num2str(file_info.start),'-',num2str(file_info.stop),'_t',num2str(iprod_thresh),'-',num2str(threshold),'-',num2str(upper_threshold),'_npt',num2str(n_bright_pixel_threshold),'-',num2str(max_pixels_above_threshold),'_e',num2str(exf),'.mat'];
            else
                impts_gray_file=[outpath,'\',file_info.part_name,'_pts_',num2str(file_info.start),'-',num2str(file_info.stop),'_t',num2str(iprod_thresh),'_e',num2str(exf),'.tif'];
                render_prop_file=[outpath,'\',file_info.part_name,'_pts_',num2str(file_info.start),'-',num2str(file_info.stop),'_t',num2str(iprod_thresh),'_e',num2str(exf),'.mat'];
            end
        end
        imwrite(uint8(impts*255),impts_gray_file,'Compression','none');
        if get(handles.adv_cb,'Value')
            save(render_prop_file,'xw','yw','ishift','jshift','exf',...
            'size_fac','total_molecules','n_rendered','lp','N','q',...
            'weight','use_lp','N_tol_min','N_tol_max','lp_tol_min',...
            'lp_tol_max','fr_un');
        else
            save(render_prop_file,'xw','yw','ishift','jshift','exf',...
            'size_fac','total_molecules','n_rendered','lp','N','q',...
            'r0_tol_min','r0_tol_max','weight','use_lp','N_tol_min','N_tol_max',...
            'lp_tol_min','lp_tol_max','fr_un');
        end
    end

    if get(handles.oc_hist,'Value') %show localization precision histogram of all localized molecules
        lp_min = min(lp)*1000;
        lp_max = max(lp)*1000;
        n_bins=round(2*total_molecules^(1/3));
        bins=linspace(lp_min,lp_max,n_bins);

        figure
        hist(lp*1000,bins);
        ylabel('Frequency');
        xlabel('Localization Precision (nm)');
    end
        