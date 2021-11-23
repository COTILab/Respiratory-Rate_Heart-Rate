function [Wxk,Hkt,centers,Vxtpix, Vxtpixbg, resid, resid_norm] = computeresidfromres(res,peval)
% [Wxk,Hkt,centers,Vxkpix, Vxkpixbg, resid, resid_norm] =
% computeresidfromres(res,peval)
[Wxk,Hkt,centers,Vxtpix]=reshapeGaP(res.hvec,res.cxcy,peval);
Vxtpixbg=reshape(Wxk*Hkt,peval.nx,peval.ny,peval.nt)+peval.bg;
resid=(Vxtpixbg-res.dpixc);
resid_norm=resid./sqrt(Vxtpixbg);