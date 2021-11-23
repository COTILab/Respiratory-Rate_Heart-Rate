% evaluate simulated data - ICA and NMF
% V ~ WH
% V -> N_pix x N_t
% W -> N_pix x N_comp - xth pixel of the ith components
% H -> N_copm x N_t - contribution of the i-th component in the time t

function separNMFICA(sep0, offset0, path_data, path_res, prename, niter, savethis, sep_how)

if ~exist('initval', 'var')
    initval = 0;
end

if ~exist('sep_how', 'var')
    sep_how = 'in';
end
ncomp = 3; %number of components to be separated + background

for rr = 1: length(offset0)
    for ll=1 : length(sep0)
        namedir = [prename num2str(100*sep0(ll)) 'offset_' num2str(offset0(rr))];
        cd ([path_data namedir])
        for mm=1:niter
            %reads the first...
            namefile = [namedir '-iter_' num2str(mm)];
            load ([namefile '.mat'])
            %cat the folowing,,,
            p.catitervec=[1];
            [dpixc, dveccr, blinkmat, p] = catsimul(namedir, p.catitervec);
            if sum(sep_how == 'i')>0 %ICA
                [icasig{mm}, A{mm}, W{mm}] = fastica (dveccr, 'numOfIC', ncomp, 'g', 'tanh');
                icapixICA{mm} = reshape(A{mm},p.nx, p.ny, ncomp);
            end
            
            if sum(sep_how == 'n')>0 %NMF
                % background estimation:
                %[out, bg(mm), bg_im]=backgroundoffset(dpixc);
                [out, bg(mm), bg_im]=backgroundoffset(dpixc, 'no', 5, 20, 8); %empirical values...
                
                dvec_bg = ones(p.nx*p.ny, 1);
                %                     dvec_bg = p.offset*ones(1, p.nx*p.ny); %changed for
                %                     offset 10...
                
                dvec_ind = squeeze(reshape(double(array2im(dpixc_ind)), p.nx*p.ny, 1, 2)); % vectors of resized images
                %                     sum_dvec_ind = sum(dvec_ind, 1);
                %                     dvec_ind = dvec_ind./repmat(sum_dvec_ind, p.nx*p.ny,1); %normlaized
                
                
                %                     winit = [f*dvec_ind'; dvec_bg];       %original 'true' points + background
                % % %                     winittmp = [dvec_ind, dvec_bg];
                winittmp = [rand(size(dvec_ind)), dvec_bg];
                sumw = sum(winittmp,1);
                winit = winittmp./repmat(sumw, p.nx*p.ny, 1); %normalized to 1
                f = mean(dveccr(:)-bg(mm))/mean(mean(winit(:, 1:2))); %ration of the data/psf
                %                     winit = [rand(ncomp, p.nx*p.ny); dvec_bg];
                blinkmatrand = rand(ncomp-1, p.Nt); %uniform random;
                hinit = [f*blinkmatrand; bg(mm)*sumw(ncomp)*ones(1, p.Nt)];             %random weights will be assigned to firts two and bg fixed
                % % %                     hinit = [f*blinkmat./repmat(mean(blinkmat,2),1,size(blinkmat,2)); bg(mm)*sumw(ncomp)*ones(1, p.Nt)];             %random weights will be assigned to firts two and bg fixed
                
                %                    [w{mm},h{mm}, wtrace{mm},wtrace{mm}]=nmf_test(double(dveccr'),ncomp+1,1,hinit,winit, [3], [3]);
                %                     [w{mm},h{mm}, wtrace,htrace,ddiv{mm}]=nmf_testconvD(double(dveccr'),ncomp+1,1,hinit,winit, [3], [3]);
                
                dvec_bg = ones(p.nx*p.ny, 1);
                winittmp = [dvec_ind, dvec_bg];
                sumw = sum(winittmp,1);
                winit = winittmp./repmat(sumw, p.nx*p.ny, 1); %normalized to 1
                f = mean(dveccr(:)-bg(mm))/mean(mean(winit(:, 1:2))); %ration of the data/psf
                
                p.Nt=1;
                p.meanblinkmat=mean(mean(blinkmat,2));                
                p.htrue=[0.3; 0.7];
                htruef=p.meanblinkmat*p.htrue;
                
                %hinit = [p.meanblinkmat*rand(2,1); p.offset*sumw(ncomp)*ones(1, p.Nt)];
                for kk=1:4
                    hinit = [p.meanblinkmat*rand(2,1); p.offset*sumw(ncomp)*ones(1, p.Nt)];
%                     hinit = [htruef; p.offset*sumw(ncomp)*ones(1, p.Nt)];
                    dveccr=dvec_ind*htruef+p.offset;
                    %[c,w{mm},h{mm}, X1,X2, dhr, minXr, miXvalr, mhdr, htrace, p]
                    [c,w{mm},h{mm}, X1,X2, dh, minX, miXval, mhd, htrace, p]=nmf_S41(double(dveccr),ncomp,1,winit,hinit, [3], [3],p);
                    res{kk}=struct('c',c,'w',w,'h',h,'X1',X1,'X2',X2,'dh',dh,'minX',minX,'miXval',miXval, 'mhd',mhd, 'htrace',htrace, 'p',p);
                end
                %hinit = [f*blinkmat./repmat(mean(blinkmat,2),1,size(blinkmat,2)); bg(mm)*sumw(ncomp)*ones(1, p.Nt)];             %random weights will be assigned to firts two and bg fixed
                %[c,w{mm},h{mm}, X1,X2, dht, minXt, miXvalt, mhdt, htrace,p]=nmf_S41(double(dveccr),ncomp,1,winit,hinit, [3], [3],p);
                qqq=[];
                icapixNMF{mm} = reshape(w{mm},p.nx,p.ny,ncomp);
            end
            
        end
        
        p.path_data = path_data;
        p.path_res = path_res;
        
        if savethis == 1
            fprintf('saving data \n');
            if ~(strcmp(path_res, path_data)) %not identical
                mkdir ([path_res namedir]);
                cd ([path_res namedir]);
            end
            %             save (p.namedir)
            %save ([namedir '_separMulti'],save ([namedir '_separMulti'],'p', 'X1','X2','dhr','minXr', 'miXvalr','dht'))
            save ([namedir '_res1_midWrandHinit'],'res')
            writedata([],[],p,[namedir '_param'])
        end
    end
end

fprintf('\n')
