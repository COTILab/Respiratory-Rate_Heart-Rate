% saves images of individual estimated components....
function varout = check_values(sep5, offset5, pathname, prename, niter)
p.path = pathname;

lot = length(offset5);
lsp = length(sep5);

for kk5 = 1: lot
    for ll5=1 : lsp
        p.namedir = [prename num2str(100*sep5(ll5)) 'offset_' num2str(offset5(kk5))];
        cd ([pathname p.namedir])
        load ([p.namedir '_res1_midWrandHinit'])
%         load S5_sep_10offset_1000/S5_sep_10offset_1000_res1_fihedHtrueRandHinit.mat
        plotHtiled(res)
        
        SaveImageFULL ('h_midWRandHinit', 'pfe')
        
        %         ims(psf);
        %         SaveImageFULL('psf', 'pf');
%         varout(kk5, ll5) = mean(bg);
%         mm=1;
%         icapixNMF{1} = reshape(w{mm},p.nx,p.ny,ncomp);
%         save ([p.namedir '_separ'], 'icapixNMF' , '-append')
%         varout = 42;
%         
        
%         varout{kk5, ll5} = ddiv{1};
% % %         for mm5=1:niter
% % %             varout = bg;
% % %             imstiled(icapixNMF{mm5}(:,:,1:2));
% % %             close all
% % %         end
    end
end
