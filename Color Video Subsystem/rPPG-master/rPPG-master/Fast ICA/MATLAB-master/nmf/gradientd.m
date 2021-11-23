function gf = gradientd(cr, varargin)
% gf = gradientd(c, varargin)
% c - position of each ceneter (2*Ncomp x 1 dimensional row vector)
% Vtx = varargin{1};  %data
% Htk = varargin{2};  %estimated H from NMF update
% sig = varargin{3};  %variance of the psf gaussian approximation
% [nx, ny] = varargin{4}; %size of the image



Vtx = varargin{1};  %data
Htk = varargin{2};  %estimated H from NMF update
sig = varargin{3};  %variance of the psf gaussian approximation
[nx, ny] = varargin{4}; %size of the image
nc = size(Htk,2);   %number of components

c=reshape(cr,2,nc); %nc x 2 dim -> centers of components

[X, Y] = meshgrid(0:nx-1, 0:ny-1);
Xnc = repmat(X,[1 1 nc]);
Ync = repmat(Y,[1 1 nc]);
cx = shiftdim(repmat(c(:,1), [1, ny, nx]),1);
cy = shiftdim(repmat(c(:,2), [1, ny, nx]),1);
Xc = Xnc-cx;
Yc = Ync-cy;
Xckx = (reshape(Xc, nx*ny, nc))';
Yckx = (reshape(Yc, nx*ny, nc))';

Wkx_mat = exp(-(Xc.^2+Yc.^2)/(2*sig^2));    %ny x nx x nc matrix - each slice is individual component...
Wkx = (reshape(Wkx_mat, nx*ny, nc))';

for jj=1:nc
    pref = -(1-Vtx./(Htk*Wkx));
    gfmatx = pref.*(Htk(:,jj)*((Xckx(jj,:)/sig^2).*(Wkx(jj,:))));
    gfmaty = pref.*(Htk(:,jj)*((Yckx(jj,:)/sig^2).*(Wkx(jj,:))));
    gf(jj, 1) = sum(gfmatx(:));
    gf(jj, 2) = sum(gfmaty(:));
end

