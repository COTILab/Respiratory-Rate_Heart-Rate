impts=zeros(yw*exf,xw*exf);
n_rendered=0;
weight=str2double(get(handles.weight,'String'));
size_fac=str2double(get(handles.size_fac_edit,'String'));

if get(handles.adv_cb,'Value') %if using advanced thresholding don't need r0 tolerances
    if get(handles.lp_N_cb,'Value') %if specifying tolerances for loc. prec.
        for i=nstart:nend
            if xc(i)>=1 && yc(i)>=1 && xc(i)<xw*exf && yc(i)<yw*exf && lp(i)*1000 >= lp_tol_min && lp(i)*1000 <= lp_tol_max && a0_err_all(i)/a0_all(i) <= fr_un && xf_err_all(i) <= max_unc && yf_err_all(i) <= max_unc
              wide=ceil(size_fac*lppix(i)*1.5+1);
              if xc(i)-wide>=1 && xc(i)+wide<xw*exf && yc(i)-wide>=1 && yc(i)+wide<yw*exf
                n_rendered=n_rendered+1;
                for j=xc(i)-wide:xc(i)+wide
                  for k=yc(i)-wide:yc(i)+wide
                    dx=double(j)-xf(i);
                    dy=double(k)-yf(i);
                    int=pi*lp2pix(i)*size_fac;
                    a=exp(-2*(dx*dx+dy*dy)/(size_fac*size_fac*lp2pix(i)))*N(i)*weight/int;
                    impts(k,j)=impts(k,j)+a;
                  end
                end
              end
            end
            waitbarxmod(i/nend,w); %update
        end
    else %if specifying tolerances for # of photons/molecule (N)
        for i=nstart:nend
            if xc(i)>=1 && yc(i)>=1 && xc(i)<xw*exf && yc(i)<yw*exf && N(i) >= N_tol_min && N(i) <= N_tol_max && a0_err_all(i)/a0_all(i) <= fr_un && xf_err_all(i) <= max_unc && yf_err_all(i) <= max_unc
              wide=ceil(size_fac*lppix(i)*1.5+1);
              if xc(i)-wide>=1 && xc(i)+wide<xw*exf && yc(i)-wide>=1 && yc(i)+wide<yw*exf
                n_rendered=n_rendered+1;
                for j=xc(i)-wide:xc(i)+wide
                  for k=yc(i)-wide:yc(i)+wide
                    dx=double(j)-xf(i);
                    dy=double(k)-yf(i);
                    int=pi*lp2pix(i)*size_fac;
                    a=exp(-2*(dx*dx+dy*dy)/(size_fac*size_fac*lp2pix(i)))*N(i)*weight/int;
                    impts(k,j)=impts(k,j)+a;
                  end
                end
              end
            end
            waitbarxmod(i/nend,w); %update
        end
    end
else %if not using advanced thresholding include r0 in tolerances
    if get(handles.lp_N_cb,'Value') %if specifying tolerances for loc. prec.
        for i=nstart:nend
            if xc(i)>=1 && yc(i)>=1 && xc(i)<xw*exf && yc(i)<yw*exf && lp(i)*1000 >= lp_tol_min && lp(i)*1000 <= lp_tol_max && r0_all(i) >= r0_tol_min && r0_all(i) <= r0_tol_max && r0_err_all(i)/r0_all(i) <= fr_un && a0_err_all(i)/a0_all(i) <= fr_un && xf_err_all(i) <= max_unc && yf_err_all(i) <= max_unc
              wide=ceil(size_fac*lppix(i)*1.5+1);
              if xc(i)-wide>=1 && xc(i)+wide<xw*exf && yc(i)-wide>=1 && yc(i)+wide<yw*exf
                n_rendered=n_rendered+1;
                for j=xc(i)-wide:xc(i)+wide
                  for k=yc(i)-wide:yc(i)+wide
                    dx=double(j)-xf(i);
                    dy=double(k)-yf(i);
                    int=pi*lp2pix(i)*size_fac;
                    a=exp(-2*(dx*dx+dy*dy)/(size_fac*size_fac*lp2pix(i)))*N(i)*weight/int;
                    impts(k,j)=impts(k,j)+a;
                  end
                end
              end
            end
            waitbarxmod(i/nend,w); %update
        end
    else %if specifying tolerances for # of photons/molecule (N)
        for i=nstart:nend
            if xc(i)>=1 && yc(i)>=1 && xc(i)<xw*exf && yc(i)<yw*exf && N(i) >= N_tol_min && N(i) <= N_tol_max && r0_all(i) >= r0_tol_min && r0_all(i) <= r0_tol_max && r0_err_all(i)/r0_all(i) <= fr_un && a0_err_all(i)/a0_all(i) <= fr_un && xf_err_all(i) <= max_unc && yf_err_all(i) <= max_unc
              wide=ceil(size_fac*lppix(i)*1.5+1);
              if xc(i)-wide>=1 && xc(i)+wide<xw*exf && yc(i)-wide>=1 && yc(i)+wide<yw*exf
                n_rendered=n_rendered+1;
                for j=xc(i)-wide:xc(i)+wide
                  for k=yc(i)-wide:yc(i)+wide
                    dx=double(j)-xf(i);
                    dy=double(k)-yf(i);
                    int=pi*lp2pix(i)*size_fac;
                    a=exp(-2*(dx*dx+dy*dy)/(size_fac*size_fac*lp2pix(i)))*N(i)*weight/int;
                    impts(k,j)=impts(k,j)+a;
                  end
                end
              end
            end
            waitbarxmod(i/nend,w); %update
        end
    end
end

thresh=impts*0+1;
impts=thresh.*(impts>thresh)+impts.*(impts<=thresh);
clear thresh;